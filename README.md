# <img src="https://s3-eu-west-1.amazonaws.com/esaude/images/esaude-logo.png" height="50px"/> eSaude EMR

eSaude EMR is an [OpenMRS](http://www.openmrs.org/) distribution for Mozambique. This repository contains installation scripts and instructions.

For more information visit [esaude.org](http://esaude.org).

## Installation

### Automated

To automatically deploy eSaude EMR using Vagrant see the [Vagrant deploy README](https://github.com/esaude/esaude-emr/tree/master/infrastructure/vagrant).

To deploy to automatically to your own **clean** Ubuntu server see the [Ubuntu deploy README] (https://github.com/esaude/esaude-emr/tree/master/infrastructure/ubuntu).

### Manual

Follow the steps below to manually instal eSaude EMR.

#### 1. Install Prerequisite Software

* Java 6
   * See instructions [here](http://www.java.com/en/download/faq/java_6.xml) for Windows and Mac.
   * To install on Ubuntu run `sudo apt-get install openjdk-6-jdk`.
   * See [this wiki page](https://wiki.openmrs.org/display/docs/Troubleshooting+Memory+Errors) for instructions on how to allocate more memory for Tomcat. On Ubuntu you can copy [this script](https://github.com/esaude/esaude-emr/tree/master/infrastructure/artifacts/setenv.sh) to `/usr/share/tomcat7/bin/` and restart Tomcat.
* Apache Tomcat 7
   * See generic install instructions [here](http://tomcat.apache.org/tomcat-7.0-doc/setup.html).
   * To install on Ubuntu run `sudo apt-get install tomcat7`.
* MySQL Server 5.6
   * Download MySQL Server for Windows and Mac [here](http://dev.mysql.com/downloads/mysql/).
   * To install on Ubuntu run `sudo apt-get install mysql-server`.

#### 2. Configure Database

Connect to MySQL server on the command line as follows:

```
$ mysql -uroot -p
```
You will have to enter the root password you chose when installing MySQL server.

[Create a database](http://dev.mysql.com/doc/refman/5.1/en/create-database.html) called `openmrs` and a [user](http://dev.mysql.com/doc/refman/5.1/en/create-user.html) called `esaude` with password, say, `esaude`. This can be done by executing the following command:

```
CREATE DATABASE openmrs;
CREATE USER 'esaude'@'localhost' IDENTIFIED BY 'esaude';
```

Grant the `esaude` user all permissions on the `openmrs` database:

```
GRANT ALL ON openmrs.* TO 'esaude'@'localhost' IDENTIFIED BY 'esaude';
```

Finally, download the eSaude EMR database from [here](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/v1.0.0/esaude-clean-database.sql.zip), extract it and import it as follows:

```
$ mysql -uroot -p openmrs < esaude-clean-database.sql
```

#### 3. Deploy eSaude EMR

First we need to create a working directory for OpenMRS called `.OpenMRS` (note the `.`). On Ubuntu it should be located at `/usr/share/tomcat7/.OpenMRS`. See [this wiki page](https://wiki.openmrs.org/display/docs/Overriding+OpenMRS+Default+Runtime+Properties) for the location on other platforms.

Create the eSaude EMR runtime settings file at `/usr/share/tomcat7/.OpenMRS/openmrs-runtime.properties` with the content listed below.

```
connection.url=jdbc:mysql://localhost:3306/openmrs?autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8
module.allow_web_admin=true
connection.username=esaude
auto_update_database=false
connection.password=esaude
```

Make sure `connection.username` and `connection.password` match the MySQL user you created above.

Download the eSaude EMR modules [here](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/v1.0.0/esaude-emr-modules.zip) and copy all of the `.omod` files into the `/usr/share/tomcat7/.OpenMRS/modules/` folder.

Lastly, copy the `openmrs.war` file from [here](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/v1.0.0/openmrs.war) into the `/var/lib/tomcat7/webapps/` folder and restart Tomcat. On Ubuntu, this is done as follows:

```
$ sudo service tomcat7 restart
```

#### Access

* **user**: admin
* **pass**: eSaude123

Support
-------

For support, visit [esaude.org](http://esaude.org) and joing the mailing list.
