#!/bin/bash

username=""
user_password=""
hostname="%"
db_name=""
table_name=""

#TODO: Add OPTION to start again if input is incorrect

# Ask for MySQL Username
read -p 'Enter MySQL Username: ' username

# Ask for MySQL root password
read -sp 'Enter MySQL Root Password: ' user_password

# Ask for MySQL Database Name
read -p 'Enter MySQL Database Name: ' db_name

# Ask for MySQL Table Name
read -p 'Enter MySQL Table Name: ' table_name
echo

# Function to check if MySQL is installed
is_mysql_installed() {
    which mysql > /dev/null 2>&1
    return $?
}

secure_mysql() {
    /usr/bin/expect <<EOF
    set timeout 10
    spawn mysql_secure_installation

    expect "Enter password for user root:"
    send "\r"

    expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
    send "n\r"

    expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect eof
EOF
}

start_mysql_if_not_running() {
    # Function to check MySQL status
    check_mysql_status() {
        systemctl is-active --quiet mysql
        return $?
    }

    # Start MySQL if it's not running
    if check_mysql_status; then
        echo "MySQL is running."
        echo
    else
        echo "MySQL is not running. Starting MySQL..."
        echo
        sudo systemctl start mysql
        # Wait for a moment to ensure MySQL has time to start
        sleep 5
        
        # Check status again after attempting to start
        if check_mysql_status; then
            echo "MySQL is now running."
            echo
        else
            echo "Failed to start MySQL. Retrying..."
            start_mysql_if_not_running
            echo
        fi
    fi
}

# Function to install and configure MySQL
install_mysql() {
    echo "MySQL is not installed. Starting installation."
    echo " ---------------------------------------------"
    
    sudo apt-get update
    echo
    echo "Installing Dependencies..."
    echo "--------------------------"
    sudo apt-get install expect
    echo
    echo "Installing MySQL..."
    echo "-------------------"
    sudo apt-get -y install mysql-server
    echo
    echo "Securing MySQL..."
    echo "-----------------"
    secure_mysql
    echo
    echo "Checking instalation of MySQL..."
    echo "--------------------------------"
    start_mysql_if_not_running
    echo
    echo "MySQL Server is installed and configured."
    echo
    echo "Opening up Port 3306 for connections..."
    echo "---------------------------------------"
    sudo ufw allow 3306	
    echo
    echo "Creating Database and user."
    echo "---------------------------"
    create_user_tables_mysql
}

create_user_tables_mysql() {
    # Access MySQL shell
sudo mysql -u root -p"$user_password" <<EOF

	-- Create a new database
	CREATE DATABASE IF NOT EXISTS $db_name;

	-- Create a new user and grant privileges
	CREATE USER IF NOT EXISTS '$username'@'$hostname' IDENTIFIED BY '$user_password';
	GRANT ALL PRIVILEGES ON $db_name.* TO '$username'@'$hostname' WITH GRANT OPTION;
	FLUSH PRIVILEGES;

	-- Verify that user was entered
	USE mysql;
	SELECT User, Host FROM user WHERE User = '$username';

	USE $db_name;

	-- Creating Table
	CREATE TABLE IF NOT EXISTS $table_name (
    		user_id INT(11) AUTO_INCREMENT PRIMARY KEY
	);
	DESC $table_name;

	-- Exit MySQL shell
EOF
        echo "-------------------------------------"
    	echo "Database, Table and user are created."
}

# TODO: Add OPTION to ADD ROWS INTO TABLES
# TODO: Add OPTION to DELETE ROWS, TABLES, DBs

# Function to uninstall MariaDB
uninstall_mariadb() {
    echo "Stopping MySQL service..."
    echo "-------------------------"
    sudo systemctl stop mysql

    echo "Removing MySQL server and client packages..."
    echo "---------------------------------------------"
    sudo apt-get remove --purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*

    echo "Optional: Removing databases, users, and configuration files..."
    read -p "Do you want to remove the databases, users, and configuration files? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo rm -rf /var/lib/mysql
      sudo rm -rf /etc/mysql
      sudo deluser mysql
      sudo rm -rf /var/run/mysqld
    fi

    echo "Removing other dependencies..."
    echo "------------------------------"
    sudo apt-get autoremove -y

    echo "Cleaning up package database..."
    echo "-------------------------------"
    sudo apt-get autoclean -y

    echo "----------------------------------"
    echo "MySQL has been completely removed."
}

# Main script
sudo apt-get update
sudo apt-get -y upgrade

if [ "$1" == "install" ]; then
    if is_mysql_installed; then

        echo "MySQL is already installed. Skipping installation."
        echo
        echo "Opening up Port 3306 for connections..."
        echo "----------------------------------------"
        sudo ufw allow 3306
        echo
        echo "Creating Database, Table and user."
        echo "----------------------------"
        create_user_tables_mysql
    else
        install_mysql
    fi
elif [ "$1" == "uninstall" ]; then
    uninstall_mariadb
else
    echo "Invalid option! Use 'install' to install MySQL or 'uninstall' to uninstall MariaDB."
fi

