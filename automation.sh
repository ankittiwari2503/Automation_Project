#Automation Script Task 2
#name="Ankit"
s3_bucket="upgrad-ankittiwari"
name="Ankit"
sudo apt update -y
apt upgrade -y

if [[ $(dpkg --get-selections apache2 | awk '{print $1}') != apache2 ]]
then
	apt install apache2 -y
fi

run=$(systemctl status apache2 | grep running | awk -F " " '{print $3}'| tr -d '()')
echo $run
if [[ $(run) -ne "running" ]]
then
	systemctl start apache2
fi
systemctl start apache2

systemctl status apache2

status=$(systemctl is-enabled apache2 | grep "enabled")
if [[ ${status} -ne "enabled" ]]
then
	systemctl enable apache2
fi
systemctl is-enabled apache2
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log

if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]
then
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi

bookkeep="/var/www/html"
if [ ! -f ${bookkeep}/inventory.html ]
then
    echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' >${bookkeep}/inventory.html
fi
if [[ -f ${bookkeep}/inventory.html ]]
then
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${bookkeep}/inventory.html
fi
if [[ ! -f /etc/cron.d/Automation ]]
then
    echo " * * * * * root/Automation_Project/Automation.sh" >> /etc/cron.d/Automation
fi
