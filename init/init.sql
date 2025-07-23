CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'zabbix'@'%' IDENTIFIED WITH mysql_native_password BY 'zabbix_pwd';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
FLUSH PRIVILEGES;
