print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}


print "Running post sudo commands"

#systemctl enable lightdm
sudo systemctl enable fstrim.timer
sed -i "/greeter-session=/c\greeter-session=lightdm-webkit2-greeter" /etc/lightdm/lightdm.conf
sed -i "/webkit_theme=/c\webkit_theme = reactive" /etc/lightdm/lightdm-webkit2-greeter.conf

print "Done"
