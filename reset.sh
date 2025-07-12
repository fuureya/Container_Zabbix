#!/bin/sh

set -e

echo "🧹 Stopping and removing containers..."
docker-compose down 

echo "🗑️ Removing named volume 'mysql_data'..."
docker volume rm -f container_zabbix_mysql_data || true

echo "🧼 Removing Zabbix-related images..."
rm -rf create.sql 
docker rmi -f \
  zabbix/zabbix-server-mysql:alpine-7.0.4 \
  zabbix/zabbix-web-nginx-mysql:alpine-7.0.4 \
  mysql:5.7 || true

echo "✅ Zabbix stack has been fully reset."
