#!/bin/bash
#sudo tar -zxvf controllers.tar.gz -C / --overwrite
shopt -s nullglob
LISTA=""
ADDONNANME=""

XMLMAGIC="merge-kodi-xml.py"
GUICHANGE="unknowsrcs.xml"
ADSSET="emu_adv_set.xml"

#testing if we should bugout before trying to automate repo install
if [ -d "/media/g*" ] || [ -d "/media/G*" ] || [ -d "/media/h*" ] || [ -d "/media/H*" ] || [ -d "/media/i*" ] || [ -d "/media/I*" ]; then
  echo "Found conflicting folder in your device, probably automounted drive. Since a folder in /media begins with g-i or G-I would effect install, we halt here"
  exit 1
fi
if [ -d "/home/osmc/w*" ] || [ -d "/home/osmc/W*" ] || [ -d "/home/osmc/x*" ] || [ -d "/home/osmc/X*" ] || [ -d "/home/osmc/y*" ] || [ -d "/home/osmc/Y*" ] || [ -d "/home/osmc/z*" ] || [ -d "/home/osmc/Z*" ]; then
  echo "Found conflicting folder in homefolder, probably a folder starting with w/W7x/X/y/Y/z/Z. Since a folder in /home/osmc begins with w-z or W-Z would effect install, we halt here"
  exit 1
fi

# Downloading Emulator binary repository  and helper repository(bios and loaders)
mkdir /home/osmc/zaddons
wget -O /home/osmc/zaddons/zutils-repo.zip https://github.com/zach-morris/repository.zachmorris/releases/download/1.0.0/repository.zachmorris-1.0.0.zip
wget -O /home/osmc/zaddons/games-repo.zip https://github.com/zach-morris/kodi_libretro_buildbot_game_addons/raw/main/repository.kodi_libretro_buildbot_game_addons_le_armhf.zip

#Downlaod and install controller-profiles
mkdir cp-tempo && cd cp-tempo
wget https://webbkontakt.net/osmc/controller-profiles.zip
unzip controller-profiles.zip
rm controller-profiles.zip
for f in *; do 
   if [ -d "$f" ]; then
      ADDONNAME+="$f "
   fi
done
LISTA=${ADDONNAME%%*( )}
ADDONNAME="$LISTA game.controller.snes game.controller.default"
for fldr in $LISTA; do
   cp -R $fldr /home/osmc/.kodi/addons
done
cd ..
rm -rf cp-tempo

# Enable libretro, change settings to acceppt unknown sources, modify advanced_settings for zip assosiation, disable libarchive
systemctl stop mediacenter
sleep 5
sqlite3 /home/osmc/.kodi/userdata/Database/Addons33.db "UPDATE installed SET enabled = 1  WHERE addonID = 'game.libretro'"
UNKNOWNSRCS=/home/osmc/.kodi/userdata/guisettings.xml
if [ -f "$UNKNOWNSRCS" ]; then
   cp $UNKNOWNSRCS guisettings_orig.xml
   /usr/bin/python3 $XMLMAGIC $UNKNOWNSRCS $GUICHANGE
else
   cp ./unknowsrcs.xml $UNKNOWNSRCS
fi
FILEN=/home/osmc/.kodi/userdata/advancedsettings.xml
if [ -f "$FILEN" ]; then
   cp $FILEN advancedsettings_orig.xml
   /usr/bin/python3 $XMLMAGIC $FILEN $ADSSET
else
   cp ./emu_adv_set.xml $FILEN
fi
sqlite3 /home/osmc/.kodi/userdata/Database/Addons33.db "UPDATE installed SET enabled = 0 WHERE addonID = 'vfs.libarchive'"

#Enable all controller-profiles
systemctl start mediacenter
echo "Prepare to wait a bit, there is a few 5-20 seconds pauses to make sure the mediacenter stops and starts properly before the next execution!"
sleep 20
mctrue=$(pgrep -c "mediacenter")
if [ $mctrue -ne 0 ]; then
       xbmc-send --action="UpdateLocalAddons"
       # let the db work for a bit
       sleep 2
       sudo systemctl stop mediacenter
       sleep 20
       for addis in $ADDONNANME; do
		sqlite3 /home/osmc/.kodi/userdata/Database/Addons33.db "UPDATE installed SET enabled = 1 WHERE addonID = '$addis'"
       done
       sudo systemctl start mediacenter
       sleep 5
       xbmc-send -a "UpdateLocalAddons"
       sleep 2
	   #Installing IAGL, Bios util repo
	   kodi-send --action="InstallFromZip"
	   kodi-send --action="Right"
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS4" ; sleep 2 ; 
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS9" ; sleep 2 ; 
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS9" ; sleep 2 ; 
	   kodi-send --action="Select"
	   sleep 10
	   #installing gamebot repo
	   kodi-send --action="InstallFromZip"
	   kodi-send --action="Right"
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS4" ; sleep 2 ; 
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS9" ; sleep 2 ; 
	   kodi-send --action="Select" ; sleep 2 ; 
	   kodi-send --action="JumpSMS4" ; sleep 2 ; 
	   kodi-send --action="Select"
fi

