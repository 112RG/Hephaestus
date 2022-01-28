# This is a bootstrap script to download the rest of the scripts and begin running them

pacman -Sy git reflector --noconfirm --needed

git clone https://github.com/112RG/Hephaestus

bash /root/Hephaestus/01-setup.sh
