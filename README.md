# idg1100-exam
If you want to automaticly host this site, follow this instruction:

1: Open terminal and type this out: 
 - cd /{your path}/idg1100-exam
 Dont type this: {your path} is where you put /idg1100-exam in your system. This is a example: /var/www/idg1100-exam or /home/emilvl/idg1100-exam
 - ./scripts/deploy_script.sh
 
-----------------------------------------------------------------------------------------------------

If you want to manually host this site, follow this instruction: 

1: Make sure you have Apache installed (run sudo apt install apache2, if not installed).

2: Place the /idg1100-exam folder inside /var/www/

3: Inside the terminal type out: sudo nano /etc/apache2/sites-available/weatherguesser.conf
 - Inside here copy everything in the /conf/weatherguesser.conf file and paste it in.

4: In terminal type out sudo nano /etc/hosts
 - Inside hosts file copy this: 127.0.0.1   weatherguesser.com 

5: inside terminal type this out: 
 - sudo a2ensite weatherguesser.conf
 - sudo systemctl reload apache2
 - sudo a2enmod cgi
 - sudo systemctl restart apache2

6: Play the game in your browser at www.weatherguesser.com.

7: Should you encounter any error when loading the game, the cause might be a permission issue. Make sure Apache and you have the neccesary permissions by running the following commands in the terminal:
 - sudo chmod +x /var/www/idg1100-exam/game.sh
 - sudo chown -R www-data:www-data /var/www/idg1100-exam

This is what i have in my crontab: 
 - */5 * * * * /var/www/idg1100-exam/cpu_disk.sh
 - * * * * * /var/www/idg1100-exam/check_apache.sh