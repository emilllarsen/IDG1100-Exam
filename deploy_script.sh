#!/bin/bash


# Here the user selects what the site is named. 
read -p "Enter det hostname of your site: " hostname

#Here the user selects where the site is located in the file system.
read -p "Enter the directory of there you want to deploy your site from. (example: /var/www/mysite):" site_directory


#This will check if the user has Apache on their system. If Apache is not installed the script will not work, so the user needs to have it!
if ! command -v apache2 &> /dev/null; then
    echo "Apache is not installed. Please install Apache first!"
    exit 1
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
cat > "$conf_file" << EOL
<VirtualHost *:80>
    ServerName $hostname
    DocumentRoot $site_directory
<Directory $site_directory>
    Options +ExecCGI
    AddHanlder cgi.script .sh
    Require all granted
</Directory>
</VirtualHost>
EOL

# This is to enable the site
sudo a2ensite "${hostname}.conf"

sudo a2enmod cgi 

# This will reload apache and it will work after. Changes will  not be set if apache is not reloaded or restarted. 
sudo systemctl reload apache2


#This will check if the hostname is already in /etc/hosts. If not it will go do the next if statment
hosts=false
while read -r line; do
    if [[ "$line" == *"$hostname"* ]]; then
        hosts=true
        break
    fi

done < /etc/hosts

#This will add the hostname to /etc/hosts if it already is not there. 
if [[ "$hosts" == false ]]; then
    echo "127.0.0.1 $hostname" >> /etc/hosts
else 
    echo "$hostname is already in /etc/hosts"
fi

sudo systemctl restart apache2 

echo "The deployment is now compleate. You can access your site at http://$hostname"
