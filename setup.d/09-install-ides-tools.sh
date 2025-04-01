#!/bin/bash

set -x
set -e

apt -y install geany geany-plugin-automark geany-plugin-lineoperations geany-plugin-overview

apt -y install emacs \
	gedit joe kate kdevelop nano vim vim-gtk3 \
	ddd valgrind ruby python3-pip konsole \
	cmake python3-matplotlib

$wget -O $cache/code_stable_amd64.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
ls -lha $cache/
dpkg -i $cache/code_stable_amd64.deb

# Install atom's latest stable version
$wget -O $cache/atom-1.60.0.deb "https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb"
dpkg -i $cache/atom-1.60.0.deb
apt -f install
# Fix #11: Atom crashes when trying to open folders
sed 's/^Exec=.*$/& --no-sandbox/' -i /usr/share/applications/atom.desktop

$wget -O $cache/nvim-linux-x86_64.tar.gz "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz"
tar xzf $cache/nvim-linux-x86_64.tar.gz -C /opt
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc

$wget -O $cache/sublime-text_stable.deb "https://download.sublimetext.com/sublime-text_build-4192_amd64.deb"
dpkg -i $cache/sublime-text_stable.deb

# Install Eclipse
$wget "https://mirror.dkm.cz/eclipse/technology/epp/downloads/release/2025-03/R/eclipse-cpp-2025-03-R-linux-gtk-x86_64.tar.gz"
tar zxf $cache/eclipse-cpp-2025-03-R-linux-gtk-x86_64.tar.gz -C /opt
cp /opt/eclipse/plugins/org.eclipse.epp.package.cpp_4.35.0.20250306-0811/eclipse256.png /usr/share/pixmaps/eclipse.png
cat - <<EOM > /usr/share/applications/eclipse.desktop
[Desktop Entry]
Name=Eclipse
Exec=env GDK_BACKEND=x11 /opt/eclipse/eclipse
Type=Application
Icon=eclipse
EOM

cat - <<EOM > /usr/share/applications/eclipse_wayland.desktop
[Desktop Entry]
Name=Eclipse (with Wayland backend)
Exec=/opt/eclipse/eclipse
Type=Application
Icon=eclipse
EOM

sed -i '/^-vmargs/a \-Dorg.eclipse.oomph.setup.donate=false' /opt/eclipse/eclipse.ini
# According to https://www.eclipse.org/forums/index.php/t/1104324/ ; see: https://github.com/ioi-2023/contestant-vm/issues/21

# Install VSCode-related stuff
# Latest as of 2025-02-06
$wget -O $cache/cpptools-linux-x64.vsix "https://github.com/microsoft/vscode-cpptools/releases/download/v1.23.6/cpptools-linux-x64.vsix"
$wget "https://github.com/VSCodeVim/Vim/releases/download/v1.29.0/vim-1.29.0.vsix"
$wget "https://github.com/kasecato/vscode-intellij-idea-keybindings/releases/download/v1.7.3/intellij-idea-keybindings-1.7.3.vsix"
$wget "https://github.com/clangd/vscode-clangd/releases/download/0.1.33/vscode-clangd-0.1.33.vsix"
rm -rf /tmp/vscode
mkdir /tmp/vscode
mkdir /tmp/vscode-extensions

code --install-extension $cache/cpptools-linux-x64.vsix --extensions-dir /tmp/vscode-extensions --user-data-dir /tmp/vscode
tar jcf /opt/ioi/misc/vscode-extensions.tar.bz2 -C /tmp/vscode-extensions .
cp $cache/vim-1.29.0.vsix /opt/ioi/misc/extra-vsc-exts/vscodevim.vsix
cp $cache/intellij-idea-keybindings-1.7.3.vsix /opt/ioi/misc/extra-vsc-exts/intellij-idea-keybindings.vsix
cp $cache/vscode-clangd-0.1.33.vsix /opt/ioi/misc/extra-vsc-exts/vscode-clangd.vsix
rm -rf /tmp/vscode-extensions
