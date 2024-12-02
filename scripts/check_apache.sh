#!/bin/bash

apache_log=/var/www/idg1100-exam/logs/apache.log
time=$(date '+%Y-%m-%d %H:%M:%S')

if sudo systemctl is-active --quiet apache2; then
    echo "apache is running" >> $apache_log
else
    echo "$time Apache is not running. Trying to restart Apache" >> $apache_log
    if sudo systemctl start apache2; then
        echo "$time -- apache succsessfully restarted" >> $apache_log
    else
        echo "$time -- failed to restart apache" >> $apache_log
    fi
fi 
