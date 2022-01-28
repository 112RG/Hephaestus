print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}


print "Cloning yay"

git clone "https://aur.archlinux.org/yay.git"

PKGS=(
	'discord-canary'
	'i3lock-fancy-rapid'
	'imgur-screenshot-git'
	'cloudflared'
	'fontweak'
	'ncdc-git'
	'paru'
	'tor-browser'
	'zoom'
	'visual-studio-code-insiders-bin'
	'polybar'
	'nerd-fonts-jetbrains-mono'
	'ttf-hack'
	'noto-fonts'
	'noto-fonts-emoji'
	'ttf-material-icons-git'
)
