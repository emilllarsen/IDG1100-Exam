# idg1100-exam
If you want to automaticly host this site, follow this instruction:

1: Open terminal and type this out:
 - cd /{your path}/idg1100-exam
 - ./deploy_script.sh
 
-----------------------------------------------------------------------------------------------------

If you want to manually host this site, follow this instruction: 

1: Make sure you have Apache installed

2: Place the idg1100-exam folder inside /var/www

3: Open the terminal and type this out: 
 - sudo chmod +x /var/www/idg1100-exam/game.sh

4: Inside the terminal type this out: 
 - sudo chown -R www-data:www-data /var/www/idg1100-exam

5: Inside the terminal type out: sudo nano /etc/apache2/sites-available/weatherguesser.conf
 - Inside here copy everything in the weatherguesser.conf file (root folder) and paste it in. 

6: In terminal type out sudo nano /etc/hosts
 - Inside hosts file copy this: 127.0.0.1   weatherguesser.com 

7: inside terminal type this out: 
 - sudo a2ensite weatherguesser.conf
 - sudo systemctl reload apache2
 - sudo a2enmod cgi
 - sudo systemctl restart apache2

This is what i have in my crontab: 
 - */5 * * * * /var/www/idg1100-exam/cpu_disk.sh
 - * * * * * /var/www/idg1100-exam/check_apache.sh