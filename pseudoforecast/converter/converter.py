import luadata

import xml.etree.ElementTree as ET
import io

# load xml

patetc={
    "SKL_SET_TARGET_CIRCLE":"Circle",
    "SKL_SET_TARGET_SQUARE": "Square",
    "SKL_SET_TARGET_FAN": "Fan",
}
patfrm={
    "CIRCLE":"Circle",
    "SQUARE": "Square",
    "FAN": "Fan",
}
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
def skilltable(frm,mode):
    if mode=="MainSkl":
        print(str(pick(frm.attrib,"Name")))
        return {
            "timestart":pick(frm.attrib,"Time"),
            "timeend":pick(frm.attrib,"AniTime"),
            "angle":pick(frm.attrib,"SklAngle"),
            "width":pick(frm.attrib,"Width"),
            "length":pick(frm.attrib,"Length"),
            "typ": patfrm[pick(frm.attrib, "Type")],
            "rotate":pick(frm.attrib,"RotAngle"),
            "mode":mode
        }
    elif mode=="Scp":
        return {
            "timestart":0,
            "timeend":1,
            "angle":pick(frm.attrib,"Angle"),
            "width":pick(frm.attrib,"Width"),
            "length":pick(frm.attrib,"Length"),
            "typ": patetc[pick(frm.attrib, "Type")],
            "rotate":pick(frm["Pos"].attrib,"RotAngle"),
            "mode":mode
        }
    return {}
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

                PSEUDOFORECAST_DATA[skill.attrib["Name"]].append(skilltable(frm,"MainSkl"))
        # etclist = mainskil.find("EtcList")
        # if (etclist):
        #     scps = etclist.findall("Scp")
        #     for scp in scps:
        #         if(pick(scp.attrib,"Scp")=="SKL_SET_TARGET_CIRCLE"):
        #
        #             if (not pick(skill.attrib,"Scp") in PSEUDOFORECAST_DATA):
        #                 PSEUDOFORECAST_DATA[skill.attrib["Name"]] = []
        #             PSEUDOFORECAST_DATA[skill.attrib["Name"]].append(skilltable(scp,"Scp"))

luadata.serialize(PSEUDOFORECAST_DATA,"skills.lua")
with open("skills.lua","a") as f:
    f.write("\nPSEUDOFORECAST_rawdata=data")