# emuprep_osmc
This is a script to prepare OSMC v.19(Bullseye), to be able to run some emulators. 

In order to run it, run these commands in a ssh-session:

		sudo apt-get update
		sudo apt-get install git
		git clone https://github.com/zjoasan/emuprep_osmc.git
		cd emuprep_osmc
		chmod +x emu_prep.sh
		./emu_prep.sh


This first daft is focused on Vero4k to begin with, I feel obligated to say there is some "guessed/calculated risk" automation, if you have any usb-drives automounted with a label begining with "G/g" or "H/h" or "I/i" or have a folder begininng with "W/w", "X/x", "Y/y" or "Z/z" in osmc homefolder, I recommend you read the script and try to manualy do what is "automated".

There is now some light error checking, will try to eveolve it. Thanks to contributions from a fellow OSMC staffer, the actual python code seems to be working (a side from when my attempts to play with things i know next to nothing about)

Still considering how to make the actual emulator installation easier, either a dedicated homepage or perhaps an interactive questioneer. Since now that we have the repos installed installing a few "often used" emulators, via this script shouldnt be that hard?
