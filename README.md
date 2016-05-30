5minutedesktop
==========

Script to install a working FreeBSD desktop (web-browser,office applications) in 5 minutes.

Contents
---------------------------------

5MinuteDesktop.sh/
  This is the main script which is tested to run on a default installation of FreeBSD 10,11. The
  script uses packages by way of pkgng to quickly build out a desktop with a working browser.
  In order for everything to work on HardenedBSD, the source package is required during installation.

  These are currently two window managers that can be passed to the script:
  
  i3
  fluxbox

How To
---------------------------------
  Run the following from a FreeBSD 10 install to setup a desktop
  
  `fetch --no-verify-peer https://raw.github.com/shirkdog/5minutedesktop/master/5MinuteDesktop.sh  && chmod 700 5MinuteDesktop.sh  && ./5MinuteDesktop.sh i3`
  
  or fluxbox instead of i3

  The last part of the script will reboot the system, and once the system is back on, you can login as a regular user and type the following (Note: a display manager is not used, as it is unnecessary to have a process running the background when there is a more efficient way to start the desktop)
  
  `startx &; lock -pn`

  (This starts X, and locks the terminal you logged in with)


TODO
---------------------------------
  Work this into an ISO file to automate the entire process.

