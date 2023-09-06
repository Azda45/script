#!/bin/bash

# Menampilkan menu pilihan
echo "Pilih web server yang ingin Anda instal:"
echo "1. Apache2"
echo "2. Nginx"

# Membaca input pengguna
read choice

case $choice in
    1)
        echo "Menginstal Apache2..."
        sudo apt install apache2
        echo "Apache2 berhasil diinstal."
        ;;
    2)
        echo "Menginstal Nginx..."
        sudo apt install nginx
        echo "Nginx berhasil diinstal."
        ;;
    *)
        echo "Pilihan tidak valid. Silakan pilih nomor 1-2."
        ;;
esac

# Install PHP, MySQL Server, dan phpMyAdmin
sudo apt install php php-mysql
sudo apt install mysql-server
sudo apt install phpmyadmin
