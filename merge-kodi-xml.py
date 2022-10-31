#!/usr/bin/env python
"""
merge-kodi-xml.py (advancedsettings.xml|guisettings.xml) patch.xml
"""

import os
import sys
from xml.etree import ElementTree


def run(files):
    payload = None

    is_advancedsettings = False
    is_guisettings = False

    for filename in files:
        parsed_xml = ElementTree.parse(os.path.join(os.getcwd(), filename))
        root = parsed_xml.getroot()

        if payload is None:
            payload = root
            is_advancedsettings = os.path.basename(filename) == 'advancedsettings.xml'
            is_guisettings = os.path.basename(filename) == 'guisettings.xml'
            if is_guisettings || is_advancedsettings:
                savexmlfile = filename 
            continue

        else:
            if root.tag != payload.tag:
                print(f'Incompatible XML files: {files[0]} <-> {filename}.')
                continue

            for child in root.findall("*"):
                if is_guisettings:
                    matched = False
                    for payload_child in payload.iter():
                        if child.tag == 'setting':
                            if child.attrib.get('id', '') and \
                                    (child.attrib.get('id', '') == payload_child.attrib.get('id')):
                                for attrib, value in child.attrib.items():
                                    payload_child.set(attrib, value)
                                payload_child.text = child.text
                                matched = True
                                break

                    if not matched and child.tag == 'setting':
                        element = ElementTree.Element('setting')
                        for attrib, value in child.attrib.items():
                            element.set(attrib, value)
                        element.text = child.text
                        payload.append(element)
                        continue

                if is_advancedsettings:
                    matched = False
                    if child.tag in [x.tag for x in root.findall("*")]:
                        for payload_child in payload.findall("*"):
                            if child.tag == payload_child.tag:
                                for root_grandchild in child.findall("*"):
                                    for payload_grandchild in payload_child.findall('*'):
                                        if root_grandchild.tag == payload_grandchild.tag:
                                            payload_child.remove(payload_grandchild)
                                            break
                                    payload_child.append(root_grandchild)
                                    matched = True

                                if matched:
                                    break

                        if not matched:
                            payload.append(child)
                            continue

    if payload:
        print(ElementTree.tostring(payload))
        parsed_xml.write(savexmlfile)

    else:
        raise Exception('Nothing to output.')


if __name__ == '__main__':
    run(sys.argv[1:])
