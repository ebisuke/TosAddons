import sys
sys.path.append('luadata')
import luadata

import xml.etree.ElementTree as ET
import io
import glob
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
PSEUDOFORECAST_DATA = {}
filelist=glob.glob("E:\\Analyze\\newtos\\extract\\skill_bytool.ipf\\*.xml")
for filename in filelist:
    with open(filename,encoding='utf_8') as f:
        data=f.read()

    root=ET.fromstring(data)
    #skills = root[0];
    def pick(attr,name):
        if name in attr:
            return attr[name]
        else:
            return 0
    def skilltable(frm,mode):
        if mode=="MainSkl":
            #print(str(pick(frm.attrib,"Name")))
            return {
                "timestart":int(pick(frm.attrib,"Time")),
                "timeend":int(pick(frm.attrib,"AniTime")),
                "angle":float(pick(frm.attrib,"SklAngle")),
                "width":float(pick(frm.attrib,"Width")),
                "length":float(pick(frm.attrib,"Length")),
                "typ": patfrm[pick(frm.attrib, "Type")],
                "rotate":float(pick(frm.attrib,"RotAngle")),
                "dist": float(pick(frm.attrib, "Dist")),
                "postype": int(pick(frm.attrib, "PosType")),
                "mode":mode
            }
        elif mode=="Scp":
            return {
                "timestart":0,
                "timeend":1,
                "angle": float(pick(frm.attrib, "SklAngle")),
                "width": float(pick(frm.attrib, "Width")),
                "length": float(pick(frm.attrib, "Length")),
                "typ": patetc[pick(frm.attrib, "Type")],
                "rotate":float(pick(frm["Pos"].attrib,"RotAngle")),
                "mode":mode
            }
        return {}
    for skill in root:
        #if( skill.attrib["Name"].startswith("Mon_")):
        #    continue
        #if (skill.attrib["Name"].find(" ")!=-1 or skill.attrib["Name"].find("-")!=-1):
        #    continue
        mainskil=skill.find("MainSkl")
        if mainskil:
            hitlist=mainskil.find("HitList")
            if(hitlist):
                frms = hitlist.findall("Frame")
                for frm in frms:
                    name =  skill.attrib["Name"]
                    name=name.replace("-","_")
                    if(not name in PSEUDOFORECAST_DATA):
                        PSEUDOFORECAST_DATA[name]=[]

                    PSEUDOFORECAST_DATA[name].append(skilltable(frm,"MainSkl"))
            # etclist = mainskil.find("EtcList")
            # if (etclist):
            #     scps = etclist.findall("Scp")
            #     for scp in scps:
            #         if(pick(scp.attrib,"Scp")=="SKL_SET_TARGET_CIRCLE"):
            #
            #             if (not pick(skill.attrib,"Scp") in PSEUDOFORECAST_DATA):
            #                 PSEUDOFORECAST_DATA[skill.attrib["Name"]] = []
            #             PSEUDOFORECAST_DATA[skill.attrib["Name"]].append(skilltable(scp,"Scp"))

luadata.serialize(PSEUDOFORECAST_DATA, "skills.lua")
with open("skills.lua","a") as f:
    f.write("\nPSEUDOFORECAST_rawdata=data")