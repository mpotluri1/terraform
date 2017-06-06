#!/bin/bash
( set -x
sudo yum -y update &&
sudo yum -y install git &&
cd /root/.ssh &&
aws s3 cp s3://arun-cloudfront-logs/aj-keys/config ./
aws s3 cp s3://arun-cloudfront-logs/aj-keys/id_rsa ./
aws s3 cp s3://arun-cloudfront-logs/aj-keys/id_rsa.pub ./

chmod 400 /root/.ssh/id_rsa &&
echo "changed permissions" &&

#installing necessary applictions

sudo yum -y install httpd mod_ssl &&
sudo /usr/sbin/apachectl start &&
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT &&
sudo service iptables save &&
sudo /sbin/chkconfig httpd on &&
sudo /sbin/chkconfig --list httpd &&
sudo yum -y install php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml &&
sudo /usr/sbin/apachectl restart &&

#starting ssh-agent
eval `ssh-agent -s`
ssh-add /root/.ssh/id_rsa

#configuring website
cd /var/www/ &&
git clone git@github.com:arunsanna/aj_site.git &&
rm -rf /var/www/html &&
mv /var/www/aj_site /var/www/html &&
rm -f /var/www/html/wp-config.php
aws s3 cp s3://arun-cloudfront-logs/aj-keys/wp-config.php /var/www/html/ &&

#final configuration
rm -rf /etc/httpd/conf/httpd.conf &&
aws s3 cp s3://arun-cloudfront-logs/aj-keys/httpd.conf /etc/httpd/conf/ &&
service httpd restart &&
echo "code completed"

) 2>&1 | tee /tmp/aj-bootstrap.log