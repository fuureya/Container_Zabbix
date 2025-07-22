#!/bin/sh

set -e

echo "[1/6] Starting Zabbix stack with docker-compose..."
docker-compose up -d --build

echo "[2/6] Extracting Zabbix schema from image..."
docker create --name temp-zabbix zabbix/zabbix-server-mysql:alpine-7.0.4 > /dev/null
docker cp temp-zabbix:/usr/share/doc/zabbix-server-mysql/create.sql.gz ./create.sql.gz
docker rm temp-zabbix > /dev/null

if [ ! -f create.sql.gz ]; then
  echo "❌ Failed to copy create.sql.gz"
  exit 1
fi

echo "[3/6] Extracting schema SQL..."
gunzip -f create.sql.gz

if [ ! -f create.sql ]; then
  echo "❌ Failed to extract create.sql"
  exit 1
fi

echo "[4/6] Waiting for MySQL to become healthy..."
for i in $(seq 1 20); do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' mysql-zabbix || echo "unknown")
  echo "Status: $STATUS"
  if [ "$STATUS" = "healthy" ]; then
    echo "✅ MySQL is healthy."
    break
  fi
  echo "⏳ Waiting for MySQL... ($i/20)"
  sleep 3
done

if [ "$STATUS" != "healthy" ]; then
  echo "❌ MySQL did not become healthy in time."
  exit 1
fi

echo "[5/6] Resetting MySQL database..."
docker exec -i mysql-zabbix mysql -uroot -proot_pass <<'EOF'
DROP DATABASE IF EXISTS zabbix;
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
FLUSH PRIVILEGES;
EOF

echo "[6/6] Importing Zabbix schema into MySQL..."
docker cp create.sql mysql-zabbix:/create.sql
docker exec mysql-zabbix sh -c "mysql -uzabbix -pzabbix_pass zabbix < /create.sql"
docker exec mysql-zabbix rm -f /create.sql
rm -f create.sql

echo "✅ Schema imported successfully. Restarting Zabbix server..."
docker restart zabbix-server > /dev/null

echo "🎉 All done! Access Zabbix at: http://localhost:9090"
