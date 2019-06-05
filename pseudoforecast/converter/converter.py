import json

import xml.etree.ElementTree as ET
import io

# load xml


with open("skill_bytool.xml",encoding='utf_8') as f:
    data=f.read()
PSEUDOFORECAST_DATA={}
root=ET.fromstring(data)
#skills = root[0];
def pick(attr,name):
    if name in attr:
        return attr[name]
    else:
        return 0
for skill in root:
    if( skill.attrib["Name"].startswith("Mon_")):
        continue
    mainskil=skill.find("MainSkl")
    if mainskil:
        hitlist=mainskil.find("HitList")
        if(hitlist):
            frms = hitlist.findall("Frame")
            for frm in frms:
                
                if(not skill.attrib["Name"] in PSEUDOFORECAST_DATA):
                    PSEUDOFORECAST_DATA[skill.attrib["Name"]]=[]

                PSEUDOFORECAST_DATA[skill.attrib["Name"]].append({
                    "timestart":pick(frm.attrib,"Time"),
                    "timeend":pick(frm.attrib,"AniTime"),
                    "angle":pick(frm.attrib,"Angle"),
                    "width":pick(frm.attrib,"Width"),
                    "length":pick(frm.attrib,"Length"),
                    "typ": pick(frm.attrib, "Type"),
                })

with open("skills.json",mode="w",encoding='utf_8') as f:
    json.dump(PSEUDOFORECAST_DATA,f)
