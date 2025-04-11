#!/bin/sh

logger -p local0.info "MKIOIUSER: Create a new IOI user"

# Create IOI account
useradd -m ioi

# Setup desktop background
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.background picture-options 'centered'
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.background picture-uri 'file:///opt/ioi/misc/ioi-wallpaper.png'
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.background picture-uri-dark 'file:///opt/ioi/misc/ioi-wallpaper.png'
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.background primary-color '#000000'
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.background secondary-color '#000000'

sudo -Hu ioi dbus-run-session gsettings set org.gnome.shell enabled-extensions "['add-username-ext', 'stealmyfocus-ext']"
sudo -Hu ioi dbus-run-session gsettings set org.gnome.shell disable-user-extensions false
# Favorites (apps in sidebar): Removed yelp (help function),
# added terminal from UI, and queried resulting setting.
sudo -Hu ioi dbus-run-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.session idle-delay 900
sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.screensaver lock-delay 30

if [ -f /opt/ioi/config/screenlock ]; then
	sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled true
else
	sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled false
fi

# Keyboard layout stuff
mkdir /home/ioi/Desktop
cp /usr/share/applications/gnome-keyboard-panel.desktop /home/ioi/Desktop
cp /opt/ioi/misc/cms.desktop /home/ioi/Desktop
chmod +x /home/ioi/Desktop/gnome-keyboard-panel.desktop
chmod +x /home/ioi/Desktop/cms.desktop
chown ioi:ioi -R /home/ioi/Desktop
sudo -Hu ioi dbus-run-session gio set /home/ioi/Desktop/gnome-keyboard-panel.desktop metadata::trusted true
sudo -Hu ioi dbus-run-session gio set /home/ioi/Desktop/cms.desktop metadata::trusted true
sudo -Hu ioi dbus-run-session gsettings set org.gnome.shell.extensions.ding start-corner top-left

# set default fullname and shell
chfn -f "IOI Contestant" ioi
chsh -s /bin/bash ioi

# Update path
echo 'PATH=/opt/ioi/bin:$PATH' >> ~ioi/.bashrc
echo "alias ioiconf='sudo /opt/ioi/bin/ioiconf.sh'" >> ~ioi/.bashrc
echo "alias ioiexec='sudo /opt/ioi/bin/ioiexec.sh'" >> ~ioi/.bashrc
echo "alias ioibackup='sudo /opt/ioi/bin/ioibackup.sh'" >> ~ioi/.bashrc
echo 'TZ=$(cat /opt/ioi/config/timezone)' >> ~ioi/.profile
echo 'export TZ' >> ~ioi/.profile

# Mark Gnome's initial setup as complete
sudo -Hu ioi bash -c 'mkdir -p ~/.config'
sudo -Hu ioi bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

sudo -Hu ioi bash -c 'mkdir -p ~ioi/.local/share/gnome-shell/extensions'
cp -a /opt/ioi/misc/add-username-ext ~ioi/.local/share/gnome-shell/extensions/
cp -a /opt/ioi/misc/stealmyfocus-ext ~ioi/.local/share/gnome-shell/extensions/
chown -R ioi:ioi ~ioi/.local/share/gnome-shell/extensions/add-username-ext
chown -R ioi:ioi ~ioi/.local/share/gnome-shell/extensions/stealmyfocus-ext

# Copy VSCode extensions
mkdir -p ~ioi/.vscode/extensions
tar jxf /opt/ioi/misc/vscode-extensions.tar.bz2 -C ~ioi/.vscode/extensions
chown -R ioi:ioi ~ioi/.vscode

# Add extra VSCode extension dir to bookmarks
mkdir -p ~ioi/.config/gtk-3.0
echo "file:///opt/ioi/misc/extra-vsc-exts" >> ~ioi/.config/gtk-3.0/bookmarks
chown -R ioi:ioi ~ioi/.config/gtk-3.0

# IOI startup
cp /opt/ioi/misc/ioistart.desktop /usr/share/gnome/autostart/

# Setup default Mozilla Firefox configuration
cp -a /opt/ioi/misc/mozilla ~ioi/.mozilla
chown -R ioi:ioi ~ioi/.mozilla

mkdir -p /home/ioi/.config/Code/User
cat >/home/ioi/.config/Code/User/settings.json <<'EOM'
{
    "C_Cpp.default.cppStandard": "gnu++17"
}
EOM
chown -R ioi:ioi /home/ioi/.config

logger -p local0.info "MKIOIUSER: IOI user created"
