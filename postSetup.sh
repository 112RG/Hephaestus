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
    'joe'

    # GENERAL UTILITIES ---------------------------------------------------

    'nautilus'              # Filesystem browser
    'nitrogen'               # Wallpaper changer
    'nemo'

    # DEVELOPMENT ---------------------------------------------------------

    'clang'                 # C Lang compiler
    'cmake'                 # Cross-platform open-source make system
    'code'                  # Visual Studio Code
    'electron'              # Cross-platform development using Javascript
    'git'                   # Version control system
    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    'meld'                  # File/directory comparison
    'python'                # Scripting language

    # MEDIA ---------------------------------------------------------------

    'feh'                   # Image viewer
)

for PKG in "${PKGS[@]}"; do
    print "Installing: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done


print "Done!"
