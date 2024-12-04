#!/bin/bash


read -p "Enter the hostname of your site:" hostname

read -p "Enter the directory of where you want to deploy your site from. (example: /var/www/mysite):" site_directory


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

#This will check if the user has jq installed on their system. If not the script will try to install it. Important to have this, because the API will not work if not. 
if ! command -v jq &> /dev/null; then
    echo "jq is not installed! Trying to install jq!"
    if sudo apt install jq -y; then
        ehco "jq is installed"
    else
        echo "Failed to install jq."
    fi
fi
#This will check if the user has sed on their system. If not the script will try to install it. sed is usally pre installed, but it is just so be sure. 
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

#This will create the directory if the scripts see that apache is installed on the system. I use sudo in case the user selects a directory that is not in their home directory.
#needs -p to tell mkdir to create the directory if it does not exist.
sudo mkdir -p "$site_directory"

#This will copy every folder to the directory that the user chooses. I use sudo if the user does not have permission to write to the directory.
sudo cp -r ../* "$site_directory"

sudo chown -R $(whoami):www-data "$site_directory"

#This is what will go into the /etc/apache2/sites-available directory to host the site on the server.
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

sudo a2ensite "${hostname}.conf" > /dev/null
echo "Site is enabled for $hostname."
sudo a2enmod cgi > /dev/null



host_file=$(sudo cat /etc/hosts)
if [[ "$host_file" == *"$hostname"* ]]; then
    echo "The $hostname already existin /etc/hosts"
else 
    echo "127.0.0.1 $hostname.com" | sudo tee -a /etc/hosts > /dev/null # need -a so we do not overwrite everything in the file. tee reads input from echo and writes it in the spesified file.
    echo "The $hostname is now added to /etc/hosts"
fi


#This will reload apache and it will work after. Changes will  not be set if apache is not reloaded or restarted. 
sudo systemctl restart apache2
echo "The deployment is now compleate. You can access your site at http://$hostname.com"
