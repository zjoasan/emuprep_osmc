#!/usr/bin/env python
# fix_advset_xml.py harpath_to_advancedsettings.xml additions.xml

import sys
from xml.etree import ElementTree

def run(files):
    first = None
    for filename in files:
        tree = ElementTree.parse(filename)
        data = tree.getroot()
        if first is None:
            first = data
            savename = filename
        else:
            first.extend(data)
    if first is not None:
        tree.write(savename)

if __name__ == "__main__":
    run(sys.argv[1:])

