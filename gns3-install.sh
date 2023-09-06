echo "menginstall gns3"
sudo apt update
sudo apt install libc6-dev libc6-i386 libssl3:i386 libc6
sudo add-apt-repository ppa:gns3/ppa
sudo dpkg --add-architecture i386
sudo apt update
sudo apt -y install gns3-gui gns3-iou gns3-server virtualbox qemu wireshark libpcap-dev git ubridge
sudo chmod 777 /usr/bin/dumpcap
sudo reboot 
echo "selesai"