# Manual Import Zabbix Database (Docker)

Langkah-langkah berikut digunakan untuk melakukan setup Zabbix menggunakan Docker Compose dan melakukan import database secara manual.

## 1. Ubah Permission Folder

Pastikan folder saat ini dapat diakses oleh container Docker:
sudo chmod 777 $(pwd)

2. Ekstrak File Schema create.sql dari Image Zabbix
   Gunakan perintah berikut untuk mengekstrak file schema:

docker run --rm -v $(pwd):/zabbix zabbix/zabbix-server-mysql:latest \
sh -c "zcat /usr/share/doc/zabbix-server-mysql\*/create.sql.gz > /zabbix/create.sql"
Alternatif (Jika Gagal karena Permission)

Jika perintah di atas gagal, gunakan opsi ini:

docker run --rm zabbix/zabbix-server-mysql:latest \
sh -c "zcat /usr/share/doc/zabbix-server-mysql\*/create.sql.gz" > create.sql

3. Hapus dan Buat Ulang Database zabbix
   Masuk ke container MySQL:

docker exec -it mysql-server mysql -uroot -proot_pass
Lalu di dalam MySQL shell, jalankan:
DROP DATABASE zabbix;
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
EXIT;

4. Import Schema ke MySQL
   Jalankan perintah berikut untuk mengimpor file create.sql ke database:
   docker exec -i mysql-server mysql -uroot -proot_pass zabbix < create.sql

5. Jalankan Layanan Zabbix
   Setelah import selesai, jalankan kembali seluruh layanan menggunakan:
   docker-compose up -d

6. Akses Zabbix Web
   Buka di browser:

http://localhost:9090
Login Default:
Username: Admin
Password: zabbix
