echo "Pilih web server yang ingin Anda instal:"
echo "1. Apache2"
echo "2. Nginx"

read choice

case $choice in
    1)
        echo "Menginstal Paket A..."
        apt install apache2
        echo "Paket A berhasil diinstal."
        ;;
    2)
        echo "Menginstal Paket B..."
        apt install nginx
        echo "Paket B berhasil diinstal."
        ;;
    *)
        echo "Pilihan tidak valid. Silakan pilih nomor 1-2."
        ;;
esac
apt install php php-mysql
apt install mysql-server
apt install phpmyadmin