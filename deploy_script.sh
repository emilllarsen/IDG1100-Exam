#!/bin/bash


# Here the user selects what the site is named. 
read -p "Enter det hostname of your site: " hostname

#Here the user selects where the site is located in the file system.
read -p "Enter the directory of there you want to deploy your site from. (example: /var/www/mysite)IMPORTANT you need to specify the directory place with /:" site_directory


#Will check if the user has apache on their system. If not the script will try to install
if ! command -v apache2 &> /dev/null; then
    echo "Apache is not installed. Trying to install Apache!"
    if sudo apt install apache2 -y; then
        echo "Apache is installed"
    else
        echo "Failed to install Apache"
    fi
fi

sudo systemctl start apache2

# This will check if the user has jq installed on their system. If not the script will try to install it. Important to have this, because the API will not work if not. 
if ! command -v jq &> /dev/null; then
    echo "jq is not installed! Trying to install jq!"
    if sudo apt install jq -y; then
        ehco "jq is installed"
    else
        echo "Failed to install jq."
    fi
fi
# This will check if the user has sed on their system. If not the script will try to install it. sed is usally pre installed, but it is just so be sure. 
if ! command -v sed &> /dev/null; then
    echo "sed in not installed. Trying to install sed"
    if sudo apt install sed -y; then
        echo "sed is installed"
    else
        echo "Failed to install sed"
    fi
fi
#This will check it the user has bc on their system. If not the script will try to install it. bc is usally pre installed, but its just to be sure. 
if ! command -v bc &> /dev/null; then
    echo "bc is not installed. Trying to install it"
    if sudo apt install bc -y; then
        echo "bc is installed"
    else
        echo "failed to install bc"
    fi
fi

# This will create the directory if the scripts see that apache is installed on the system. I use sudo in case the user selects a directory that is not in their home directory.
sudo mkdir -p "$site_directory"

#This will copy every file to the directory that the user chooses. I use sudo if the user does not have permission to write to the directory.
sudo cp ./index.html ./template.html ./game.sh ./style.css ./weatherguesser.conf ./README.md "$site_directory"
echo "All the files is now copyed to your $site_directory"

# This is for the bashscript to executable. 
sudo chmod +x "$site_directory/game.sh"

#This is for apache to accsess to have permission. Else the site will not work. 
sudo chown -R www-data:www-data "$site_directory"


# This is what will go into the /etc/apache2/sites-available directory to host the site on the server.
conf_file="/etc/apache2/sites-available/${hostname}.conf"
sudo bash -c "cat > $conf_file" << EOL
<VirtualHost *:80>
        ServerName $hostname.com
        DocumentRoot $site_directory
    <Directory $site_directory>
        Options +ExecCGI
        AddHandler cgi-script .sh
        Require all granted
    </Directory>
</VirtualHost>
EOL

# This is to enable the site
sudo a2ensite "${hostname}.conf"
echo "Site is enabled for $hostname. No need to reload Apache."
sudo a2enmod cgi


#This will check if the hostname is already in /etc/hosts. If not it will go do the next if statment
host_file=$(sudo cat /etc/hosts)
if [[ "$host_file" == *"$hostname"* ]]; then
    echo "The $hostname already existin /etc/hosts"
else 
    echo "127.0.0.1 $hostname.com" | sudo tee -a /etc/hosts > /dev/null
    echo "The $hostname is now added to /etc/hosts"
fi


# This will reload apache and it will work after. Changes will  not be set if apache is not reloaded or restarted. 
sudo systemctl restart apache2
echo "The deployment is now compleate. You can access your site at http://$hostname.com"
