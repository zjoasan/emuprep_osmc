#!/usr/bin/env python
# fix_guiset_xml.py hard_path_to_guisettings.xml

import sys
from xml.etree import ElementTree

def run(filename):
    first = None
    tree = ElementTree.parse(filename)
    data = tree.getroot()
    for seting in data.findall('setting'):
        setid = seting.get('addons.unknownsources')
        if setid.text != 'true' :
            setid.text('true')
        settid = seting.get('addons.updatemode')
        if settid.text != '1' :
            settid.text('1')
    tree.write(filename)
    
if __name__ == "__main__":
    run(sys.argv[1:])
