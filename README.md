5minutedesktop
==========

Script to install a working FreeBSD desktop (web-browser,office applications) in 5 minutes.

Contents
---------------------------------

5MinuteDesktop.sh/
  This is the main script which is tested to run on a default installation of FreeBSD 10. The
  script uses packages by way of pkgng to quickly build out a desktop with a working browser.

  These are currently two window managers that can be passed to the script:
  
  i3
  fluxbox

How To
---------------------------------
  Run the following from a FreeBSD 10 install to setup a desktop
  
  fetch --no-verify-peer https://raw.github.com/shirkdog/5minutedesktop/master/5MinuteDesktop.sh  && chmod 700 5MinuteDesktop.sh  && ./5MinuteDesktop.sh i3
  
  or fluxbox instead of i3


TODO
---------------------------------
  Work this into an ISO file to automate the entire process, based on FreeBSD 10 pkgng repo

