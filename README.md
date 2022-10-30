# emuprep_osmc
This is a script to prepare OSMC v.19(Bullseye), to be able to run some emulators. 

This first daft is focused on Vero4k to begin with, I feel obligated to say there is some "guessed/calculated risk" automation, if you have any usb-drives automounted with a label begining with "G/g" or "H/h" or "I/i" or have a folder begininng with "W/w", "X/x", "Y/y" or "Z/z" in osmc homefolder, I recommend you read the script and try to manualy do what is "automated".

There is now some light error checking, will try to eveolve it. Chose to go with two different python script for the two xml files we have to parse. Hope to get some feedback from someone who knows python better.

Still considering how to make the actual emulator installation easier, either a dedicated homepage or perhaps an interactive questioneer.
