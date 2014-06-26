# Defaults for exec
Exec {
	path => ["/bin", "/usr/bin", "/usr/local/bin", "/usr/local/sbin"],
	user => "root"
}

# Install Apache
class { "apache": }

# Configure default host
apache::vhost { "default":
    source      => "/esaude/infrastructure/artifacts/appliance/default",
    template    => "",
    priority 	=> ""
}

# Enable WebDAV module
apache::module { "dav_fs": }

# Create WedDAV directory
file { "/var/www/files":
    ensure 	=> "directory",
    owner	=> "root",
	group 	=> "root",
	require	=> Class["apache"]
}

# Password protect files
file { "/etc/apache2/passwd.dav":
	source 	=> "/esaude/infrastructure/artifacts/appliance/passwd.dav",
    owner	=> "www-data",
	group 	=> "www-data",
	mode 	=> 0660,
	notify => Service["apache2"]
}

# Put scripts in place
define esaude-scripts {
  file { "${title}":
    source  => "/esaude/infrastructure/artifacts/appliance/scripts${title}",
    owner   => "root",
    group   => "root",
    mode    => "a+x",
    ensure  => present,
  }
}

# Copy friendly homepage
file { "/var/www/index.html":
	source 	=> "/esaude/infrastructure/artifacts/appliance/index.html",
    owner	=> "www-data",
	group 	=> "www-data",
	require => Class["apache"]
}

$scripts = [
	"/etc/issue",
	"/etc/network/if-up.d/show-ip-address",
	"/usr/bin/esaude-backup",
	"/usr/bin/esaude-clean-files",
	"/usr/bin/esaude-show-menu",
	"/usr/bin/get-ip-address",
	"/usr/bin/show-menu",
	"/usr/bin/tomcat-log-publish",
	"/usr/bin/tomcat-log-show",
	"/usr/bin/tomcat-restart"
	]

esaude-scripts { $scripts: }

# Customize MOTD
file { "/etc/update-motd.d":
	ensure  => "directory",
	source 	=> "/esaude/infrastructure/artifacts/appliance/scripts/etc/update-motd.d",
	recurse => "true",
    owner	=> "root",
	group 	=> "root",
	mode 	=> "a+x",
	purge   => "true"
}
