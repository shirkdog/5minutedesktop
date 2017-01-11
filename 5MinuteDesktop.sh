#!/bin/csh
#
# FreeBSD 5 Minute Desktop Build
#
# Version: 1.7
#
# Tested on FreeBSD/HardenedBSD default install with ports and source code
# Tested on VirtualBox with Guest Drivers Installed
# Tested on and works poorly with NVIDIA Cards (default X drivers are used)
# 
# Copyright (c) 2016, Michael Shirk
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this 
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

setenv PATH "/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin"

set WM = "NONE"

if ($#argv == 0) then
	echo "FreeBSD 5 Minute Desktop Build"
	echo "Usage: $argv[0] i3 or fluxbox"
	exit 13
endif

if ($argv[1] == "fluxbox") then
	set WM = "fluxbox"
endif

if ($argv[1] == "i3") then 
	set WM = "i3"
endif

if ("$WM" == "NONE") then
	echo "FreeBSD 5 Minute Desktop Build"
	echo "Usage: $argv[0] i3 or fluxbox"
	exit 13
endif

#pkgng needs to be bootstrapped. 
env ASSUME_ALWAYS_YES=YES pkg bootstrap

#Update Packages
env ASSUME_ALWAYS_YES=YES pkg update -f

#Install everything
pkg install -y xorg-server xinit xterm xauth xscreensaver xf86-input-keyboard xf86-input-mouse 

#WM Specific i3 or fluxbox
if ( $WM == "i3" ) then
	pkg install -y i3 i3lock i3status
	foreach dir (`ls /usr/home`)
		echo "/usr/local/bin/i3" >> /usr/home/$dir/.xinitrc
		chown $dir /usr/home/$dir/.xinitrc
	end
else if ($WM == "fluxbox") then
	pkg install -y fluxbox
	foreach dir (`ls /usr/home`)
		echo "/usr/local/bin/fluxbox" >> /usr/home/$dir/.xinitrc
		chown $dir /usr/home/$dir/.xinitrc
	end
endif

set VBOX = `dmesg|grep -oe VBOX|uniq`
#If running on Vbox, setup services
if ( "$VBOX" == "VBOX" ) then
        pkg install -y virtualbox-ose-additions
	sysrc vboxguest_enable="YES"
	sysrc vboxservice_enable="YES"
else
#Otherwise, install failsafe drivers with vesa
pkg install -y xorg-drivers
endif

#Other stuff to make life easier, looping in case packages change
foreach i ( rxvt-unicode zsh sudo firefox chromium tmux libreoffice4 gnupg pinentry-curses enaspell en-hunspell ) 
pkg install -y $i
end

#necessary for linux compat and chrome/firefox
echo 'sem_load="YES"' >> /boot/loader.conf
echo 'linux_load="YES"' >> /boot/loader.conf

#replaces systemd on FreeBSD with faster booting
echo 'autoboot_delay="1"' >> /boot/loader.conf

#rc updates for X
sysrc hald_enable="YES"
sysrc dbus_enable="YES"

#sysctl values for chromium,audio and disabling CTRL+ALT+DELETE
cat << EOF >> /etc/sysctl.conf
#Required for chrome
kern.ipc.shm_allow_removed=1
#Don't allow CTRL+ALT+DELETE
hw.syscons.kbd_reboot=0
# fix for HDA sound playing too fast/too slow. only if needed.
# dev.pcm.0.play.vchanrate=44100
EOF

#If running on HardenedBSD, configure applications to work.
set HARD = `sysctl hardening.version`
if ( $status == 0 ) then
	#install secadm from secadm src (requires HardenedBSD Source to be installed)
 	pkg install -y git-lite
 	cd /usr
 	/usr/local/bin/git clone https://github.com/hardenedbsd/secadm.git
 	cd /usr/secadm/
 	/usr/local/bin/git pull && make && make install

	#setup secadm module to load at boot
	echo 'secadm_load="YES"' >> /boot/loader.conf

	#create the current application rules for secadm
	#based on v0.3 rules from https://github.com/HardenedBSD/secadm-rules
	cat << EOF >> /usr/local/etc/secadm.rules
secadm {
        pax {
                path: "/usr/local/share/chromium/chrome",
                  mprotect: false,
                  pageexec: false,
        },
        pax {
                path: "/usr/local/lib/firefox/firefox",
                  mprotect: false,
                  pageexec: false,
        },
        pax {
                path: "/usr/local/lib/libreoffice/program/soffice.bin",
                  mprotect: false,
                  pageexec: false,
        },
}
EOF

	chmod 0500 /usr/local/etc/secadm.rules
	chflags schg /usr/local/etc/secadm.rules

	#set secadm to start at bootime
	sysrc secadm_enable="YES"
fi

#reboot for all modules and services to start
reboot

