# Variables
$mysql_root_password = "esaude-mysql-root-pass"
$mysql_esaude_user = "esaude"
$mysql_esaude_user_password = "esaude"
$mysql_esaude_database_name = "openmrs"

# Defaults for exec
Exec {
	path => ["/bin", "/usr/bin", "/usr/local/bin", "/usr/local/sbin"],
	user => "root"
}

# Grab the clean esaude database from S3
exec { "download-esaude-database":
	cwd	=> "/esaude/infrastructure/artifacts",
	command	=> "wget https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/esaude-clean-database.sql.zip",
	creates => "/esaude/infrastructure/artifacts/esaude-clean-database.sql.zip",
	timeout	=> 0
}

# Grab the OpenMRS WAR from S3
exec { "download-esaude-war":
	cwd	=> "/esaude/infrastructure/artifacts",
	command	=> "wget https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/openmrs.war",
	creates => "/esaude/infrastructure/artifacts/openmrs.war",
	timeout	=> 0
}

# Grab the OpenMRS modules from S3
exec { "download-esaude-modules":
	cwd	=> "/esaude/infrastructure/artifacts",
	command	=> "wget https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/esaude-emr-modules.zip",
	creates => "/esaude/infrastructure/artifacts/esaude-emr-modules.zip",
	timeout	=> 0
}

# Install MySQL server
class { "mysql::server":
	root_password => $mysql_root_password
}

# Install zip
package {"zip":
	ensure	=> latest,
}

# Install unzip
package {"unzip":
	ensure	=> latest,
}

# Extract the database
exec { "extract-esaude-database": 
	cwd	=> "/esaude/infrastructure/artifacts",
	command	=> "unzip esaude-clean-database.sql.zip",
	creates => "/esaude/infrastructure/artifacts/esaude-clean-database.sql",
	require => Package["unzip"]
}

# Create esaude database
mysql::db { $mysql_esaude_database_name: 
	user		=> $mysql_esaude_user,
	password	=> $mysql_esaude_user_password,
	sql      	=> "/esaude/infrastructure/artifacts/esaude-clean-database.sql",
	host		=> "localhost",
	grant		=> ["all"],
	require		=> [ Class["mysql::server"], Exec["extract-esaude-database"] ]
}

# Install Java 6
package { "openjdk-6-jdk": 
	ensure	=> latest
}

# Install Tomcat
package { "tomcat7": 
	ensure	=> latest,
	require => Package["openjdk-6-jdk"]
}

# Define Tomcat service
service { "tomcat7":
    ensure  => "running",
    enable  => "true",
    require => Package["tomcat7"],
}

# Configure Tomcat memory
file { "/usr/share/tomcat7/bin/setenv.sh":
	source	=> "/esaude/infrastructure/artifacts/setenv.sh",
	owner	=> "tomcat7",
	group 	=> "tomcat7",
	mode 	=> "a+x",
	require => Package["tomcat7"],
	notify 	=> Service["tomcat7"]
}

# Create OpenMRS directory structure
file { [ "/usr/share/tomcat7/.OpenMRS", "/usr/share/tomcat7/.OpenMRS/modules"]:
    ensure 	=> "directory",
    owner	=> "tomcat7",
	group 	=> "tomcat7",
	require	=> Package["tomcat7"]
}

# Copy runtime properties into place
file { "/usr/share/tomcat7/.OpenMRS/openmrs-runtime.properties":
	source	=> "/esaude/infrastructure/artifacts/openmrs-runtime.properties",
	owner	=> "tomcat7",
	group 	=> "tomcat7",
	require => File["/usr/share/tomcat7/.OpenMRS"],
	notify  => Service["tomcat7"]
}

# Copy modules into place
exec { "install-esaude-modules": 
	cwd	=> "/esaude/infrastructure/artifacts",
	command	=> "unzip -o esaude-emr-modules.zip -d /usr/share/tomcat7/.OpenMRS/modules",
	require => [ Package["unzip"], File["/usr/share/tomcat7/.OpenMRS/openmrs-runtime.properties"] ],
	notify  => Service["tomcat7"]
}

# Deploy OpenMRS WAR file
file { "/var/lib/tomcat7/webapps/openmrs.war":
	source	=> "/esaude/infrastructure/artifacts/openmrs.war",
	owner	=> "tomcat7",
	group 	=> "tomcat7",
	require => Exec["install-esaude-modules"],
	notify  => Service["tomcat7"]
}

# Fix Tomcat index
file { "/var/lib/tomcat7/webapps/ROOT/index.html":
	source	=> "/esaude/infrastructure/artifacts/tomcat-index.html",
	owner	=> "tomcat7",
	group 	=> "tomcat7",
	require => File["/var/lib/tomcat7/webapps/openmrs.war"]
}
