print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

PKGS=(

    # TERMINAL UTILITIES --------------------------------------------------
    'curl'                    # Remote content retrieval
    'gtop'                    # System monitoring via terminal
    'hardinfo'                # Hardware info app
    'htop'                    # Process viewer
    'neofetch'                # Shows system info when you launch terminal
    'ntp'                     # Network Time Protocol to set time via network.
    'numlockx'                # Turns on numlock in X11
    'p7zip'                   # 7z compression program
    'rsync'                   # Remote file sync utility
    'speedtest-cli'           # Internet speed via terminal
    'terminus-font'           # Font package with some bigger fonts for login terminal
    'unrar'                   # RAR compression program
    'unzip'                   # Zip compression program
    'wget'                    # Remote content retrieval
    'alacritty'              # Terminal emulator
    'vim'                     # Terminal Editor
    'zip'                     # Zip compression program
    'bat'
    'exa'
    'nano'
    'fish'
    # GENERAL UTILITIES ---------------------------------------------------

    'nautilus'              # Filesystem browser
    'nitrogen'               # Wallpaper changer
    'nemo'
    'picom'
    'curl'

    # DEVELOPMENT ---------------------------------------------------------

    'git'                   # Version control system
    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    'python'                # Scripting language

    # MEDIA ---------------------------------------------------------------

    'feh'                   # Image viewer

    # DE ------------------------------------------------------------------
    'xss-lock'    
    'i3-gaps'
    'ttf-dejavu'
    'ttf-jetbrains-mono'
    'lightdm'
    'lightdm-webkit2-greeter'
    'lightdm-gtk-greeter'
    'xorg'
    'xorg-server'
    'rofi'

)

for PKG in "${PKGS[@]}"; do
    print "Installing: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done


git clone "https://aur.archlinux.org/yay.git"

cd /home/thor/yay
makepkg -si  --noconfirm 
AUR_PKGS=(
	'discord-canary'
	'i3lock-fancy-rapid-git'
	'imgur-screenshot-git'
	'cloudflared'
	'fontweak'
	'ncdc-git'
	'tor-browser'
	'zoom'
	'visual-studio-code-insiders-bin'
	'polybar'
	'nerd-fonts-jetbrains-mono'
	'ttf-hack'
	'noto-fonts'
	'noto-fonts-emoji'
	'ttf-material-icons-git'
    'lightdm-webkit2-theme-reactive'
)

for AUR_PKGS in "${AUR_PKGS[@]}"; do
    yay -S --noconfirm $AUR_PKGS
done

git clone  /home/thor
git clone --bare https://github.com/112RG/dotfiles.git /home/thor/.dotfiles
git --git-dir=/home/thor/.dotfiles/ --work-tree=/home/thor/ checkout -f
git --git-dir=/home/thor/.dotfiles/ --work-tree=/home/thor/ config --local status.showUntrackedFiles no

chsh -s $(which fish)

curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

print "Done!"
