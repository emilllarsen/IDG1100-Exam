#!/bin/bash

cpu_disk_log=/var/www/idg1100-exam/cpu_disk.log

usage_cpu=$(top -bn1 | awk '/Cpu\(s\): / {print 100 - $8"%"}')
space_disk=$(df -h / | awk 'NR==2 {print $5}')

echo "CPU usage is $usage_cpu and available disk space is $space_disk" >> $cpu_disk_log



