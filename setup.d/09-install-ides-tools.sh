#!/bin/bash

set -x
set -e

ATOM_VERSION="1.60.0"
ECLIPSE_VERSION="2025-03"
NVIM_VERSION="v0.11.0"
SUBLIME_VERSION="4192"
VSCODE_CPPT_VERSION="1.24.5"
VSCODE_VIM_VERSION="1.29.0"
VSCODE_CLANGD_VERSION="0.1.33"
VSCODE_INTELLIJ_VERSION="1.7.3"

apt -y install firefox geany geany-plugin-automark geany-plugin-lineoperations geany-plugin-overview

apt -y install emacs \
	gedit joe kate kdevelop nano vim vim-gtk3 \
	ddd valgrind ruby python3-pip konsole \
	cmake python3-matplotlib

$wget -O "$cache/code_stable_amd64.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
dpkg -i "$cache/code_stable_amd64.deb"

$wget -O "$cache/atom.deb" "https://github.com/atom/atom/releases/download/v${ATOM_VERSION}/atom-amd64.deb"
dpkg -i "$cache/atom.deb"
apt -f install
# Fix #11: Atom crashes when trying to open folders
sed 's/^Exec=.*$/& --no-sandbox/' -i /usr/share/applications/atom.desktop

$wget -O "$cache/nvim-linux-x86_64.tar.gz" "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
tar xzf "$cache/nvim-linux-x86_64.tar.gz" -C /opt
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> /home/ioi/.bashrc

$wget -O "$cache/sublime-text.deb" "https://download.sublimetext.com/sublime-text_build-${SUBLIME_VERSION}_amd64.deb"
dpkg -i "$cache/sublime-text.deb"

# Install Eclipse
$wget -O "$cache/eclipse-cpp.tar.gz" "https://mirror.dkm.cz/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-cpp-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz"
tar zxf "$cache/eclipse-cpp.tar.gz" -C /opt
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
$wget -O "$cache/cpptools-linux-x64-${VSCODE_CPPT_VERSION}.vsix" "https://github.com/microsoft/vscode-cpptools/releases/download/v${VSCODE_CPPT_VERSION}/cpptools-linux-x64.vsix"
$wget -O "$cache/vim-${VSCODE_VIM_VERSION}.vsix" "https://github.com/VSCodeVim/Vim/releases/download/v${VSCODE_VIM_VERSION}/vim-${VSCODE_VIM_VERSION}.vsix"
$wget -O "$cache/intellij-idea-keybindings-${VSCODE_INTELLIJ_VERSION}.vsix" "https://github.com/kasecato/vscode-intellij-idea-keybindings/releases/download/v${VSCODE_INTELLIJ_VERSION}/intellij-idea-keybindings-${VSCODE_INTELLIJ_VERSION}.vsix"
$wget -O "$cache/vscode-clangd-${VSCODE_CLANGD_VERSION}.vsix" "https://github.com/clangd/vscode-clangd/releases/download/${VSCODE_CLANGD_VERSION}/vscode-clangd-${VSCODE_CLANGD_VERSION}.vsix"

rm -rf /tmp/vscode
mkdir /tmp/vscode
mkdir /tmp/vscode-extensions

sudo -u ioi code --install-extension "$cache/cpptools-linux-x64-${VSCODE_CPPT_VERSION}.vsix"
tar jcf /opt/ioi/misc/vscode-extensions.tar.bz2 -C /tmp/vscode-extensions .
cp "$cache/vim-${VSCODE_VIM_VERSION}.vsix" /opt/ioi/misc/extra-vsc-exts/vscodevim.vsix
cp "$cache/intellij-idea-keybindings-${VSCODE_INTELLIJ_VERSION}.vsix" /opt/ioi/misc/extra-vsc-exts/intellij-idea-keybindings.vsix
cp "$cache/vscode-clangd-${VSCODE_CLANGD_VERSION}.vsix" /opt/ioi/misc/extra-vsc-exts/vscode-clangd.vsix
rm -rf /tmp/vscode-extensions

# Configuration for C++ standard and compiler path
VSCODE_SETTINGS_DIR="/home/ioi/.config/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

mkdir -p "$VSCODE_SETTINGS_DIR"

cat <<EOF > "$VSCODE_SETTINGS_FILE"
{
  "C_Cpp.default.cppStandard": "gnu++20",
  "C_Cpp.default.compilerPath": "/usr/bin/g++",
  "extensions.ignoreRecommendations": true,
  "extensions.showRecommendationsOnlyOnDemand": true
}
EOF

chown -R ioi:ioi "$VSCODE_SETTINGS_DIR"