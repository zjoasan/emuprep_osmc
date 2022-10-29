#!/bin/bash
#sudo tar -zxvf controllers.tar.gz -C / --overwrite
shopt -s nullglob
LISTA=""
ADDONNANME=""
SCRIPT_PATH="${BASH_SOURCE}"
while [ -L "${SCRIPT_PATH}" ]; do
  TARGET="$(readlink "${SCRIPT_PATH}")"
  if [[ "${TARGET}" == /* ]]; then
    SCRIPT_PATH="$TARGET"
  else
    SCRIPT_PATH="$(dirname "${SCRIPT_PATH}")/${TARGET}"
  fi
done
$FOLDER=$SCRIPT_PATH
XMLMAGIC="$FOLDER/fix_kodi-xml_set.py"
GUICHANGE="$FOLDER/unknowsrcs.xml"
ADSSET="$FOLDER/emu_adv_set.xml"

#testing if we should bugout before trying to automate repo install
if [ -d "/media/g*" ] || [ -d "/media/G*" ] || [ -d "/home/osmc/h*" ] || [ -d "/home/osmc/H*" ] || [ -d "/media/i*" ] || [ -d "/media/I*" ]; then
  echo "Found conflicting folder in your device, probably automounted drive. Since a folder in /media begins with g-i or G-I would effect install, we halt here"
  exit 1
fi

# Downloading Emulator binary repository  and helper repository(bios and loaders)
cd /home/osmc && mkdir zaddons && cd zaddons
wget -O zutils-repo.zip https://github.com/zach-morris/repository.zachmorris/releases/download/1.0.0/repository.zachmorris-1.0.0.zip
wget -O games-repo.zip https://github.com/zach-morris/kodi_libretro_buildbot_game_addons/raw/main/repository.kodi_libretro_buildbot_game_addons_le_armhf.zip
cd $FOLDER

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
echo "pause for mediacenter to start inorder to controll it from script!"
sleep 10
mctrue=$(pgrep -c "mediacenter")
if [ $mctrue -ne 0 ]; then
       xbmc-send --action="UpdateLocalAddons"
       # let the db work for a bit
       sleep 2
       sudo systemctl stop mediacenter
       for addis in $ADDONNANME; do
		sqlite3 /home/osmc/.kodi/userdata/Database/Addons33.db "UPDATE installed SET enabled = 1 WHERE addonID = '$addis'"
       done
       sudo systemctl start mediacenter
       sleep 2
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

