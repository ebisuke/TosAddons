import sys
sys.path.append('luadata')
import luadata

import xml.etree.ElementTree as ET
import io
import glob
# load xml
#skills = root[0];
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
def pick(attr,name):
    if name in attr:
        return attr[name]
    else:
        return 0
def skilltable(frm,mode,scptype):
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
        inner = frm.findall("./")
        if scptype=="SKL_SET_TARGET_CIRCLE":

            return {
                "timestart":int(pick(frm.attrib,"Time")),
                "timeend":int(pick(frm.attrib,"AniTime")),
                "angle": 0,
                "width": 0,
                "length": float(pick(inner[1].attrib, "Num")),
                "typ": "Circle",
                "rotate":0,
                "mode":mode,
                "scptype": scptype,
            }
        elif scptype=="SKL_TGT_BUFF":
            return {
                "timestart": int(pick(frm.attrib,"Time")),
                "timeend": int(pick(frm.attrib,"AniTime")),
                "angle": float(pick(inner[2].attrib,"Angle")),
                "width": float(pick(inner[2].attrib,"Width")),
                "length": float(pick(inner[2].attrib,"Dist")),
                "typ": pick(inner[2].attrib,"PosType"),
                "rotate": 0,
                "mode": mode,
                "name": pick(inner[0].attrib,"Str"),
                "scptype": scptype,
            }
        elif scptype == "PAD_SEARCH_AND_CHANGE_TARGET":
            return {
                "timestart": 0,
                "timeend": int(pick(frm.attrib, "Time")),
                "source": pick(inner[0].attrib, "Str"),
                "destination": pick(inner[1].attrib, "Str"),
                "angle": 0,
                "width": 0,
                "length": float(pick(frm.attrib, "Length")),
                "typ": "Circle",
                "rotate": 0,
                "mode": mode,
                "name": pick(inner[0].attrib, "Str"),

            }
        elif scptype == "MONSKL_CRE_PAD":
            return {
                "scptype": scptype,
                "timestart": 0,
                "timeend": int(pick(frm.attrib, "Time")),
                "source":pick(inner[0].attrib, "Str"),
                "width": float(pick(inner[0].attrib, "Width")),
                "length": float(pick(inner[0].attrib, "Dist")),
                "angle": float(pick(inner[1].attrib, "Dist")),
                "pad":pick(inner[2].attrib, "Str"),
                "mode": mode,
                "scptype": scptype,
            }
        elif scptype == "MSL_PAD_THROW":
            return {
                "scptype": scptype,
                "timestart": 0,
                "timeend": 0,
                "width": 0,
                "length": 0,
                "angle":0,
                "pad":pick(inner[15].attrib, "Str"),
                "mode": mode,
                "scptype": scptype,
            }
    elif mode == "PadSkill":
        checkertype=int(pick(frm.attrib, "CheckerType"))
        if (checkertype ==0 or checkertype ==4 ):
            return {
                "timestart": 0,
                "timeend": 0,
                "angle": float(pick(frm.attrib, "Angle")),
                "width": float(pick(frm.attrib, "Range")),
                "length": float(pick(frm.attrib, "InnerRange")),
                "typ": "Circle",
                "rotate": 0,
                "mode": mode,
                "checkertype": checkertype,
                "updateterm": int(pick(frm.attrib, "UpdateTerm")),
            }
        elif(checkertype==1):
            return {
                "timestart": 0,
                "timeend": 0,
                "angle": float(pick(frm.attrib, "Angle")),
                "width": float(pick(frm.attrib, "Range")),
                "length":float(pick(frm.attrib, "InnerRange")),
                "typ": "Square",
                "rotate": 0,
                "mode": mode,
                "checkertype":checkertype,
                "updateterm":int(pick(frm.attrib, "UpdateTerm")),
            }
    return {}


PSEUDOFORECAST_DATA = {}
PSEUDOFORECAST_PADDATA = {}
filelist=glob.glob("xml/*.xml")
for filename in filelist:
    with open(filename,encoding='utf_8') as f:
        data=f.read()

    root=ET.fromstring(data)

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
                    PSEUDOFORECAST_DATA[name].append(skilltable(frm,"MainSkl",None))
            etclist = mainskil.find("EtcList")
            if (etclist):
                scps = etclist.findall("Scp")
                for scp in scps:
                    scptype=pick(scp.attrib,"Scp")
                    if(scptype=="SKL_SET_TARGET_CIRCLE"):
                        name = skill.attrib["Name"]
                        name = name.replace("-", "_")
                        if (not name in PSEUDOFORECAST_DATA):
                            PSEUDOFORECAST_DATA[name] = []
                        PSEUDOFORECAST_DATA[name].append(skilltable(scp,"Scp",scptype))
                    if (scptype == "MONSKL_CRE_PAD"):
                        name = skill.attrib["Name"]
                        name = name.replace("-", "_")
                        if (not name in PSEUDOFORECAST_DATA):
                            PSEUDOFORECAST_DATA[name] = []
                        PSEUDOFORECAST_DATA[name].append(skilltable(scp, "Scp", scptype))
                    if (scptype == "MSL_PAD_THROW"):
                            name = skill.attrib["Name"]
                            name = name.replace("-", "_")
                            if (not name in PSEUDOFORECAST_DATA):
                                PSEUDOFORECAST_DATA[name] = []
                            PSEUDOFORECAST_DATA[name].append(skilltable(scp, "Scp", scptype))
luadata.serialize(PSEUDOFORECAST_DATA, "skills.lua")
with open("skills.lua", "a") as f:
    f.write("\nPSEUDOFORECAST_rawdata=data")
with open("./xml/pad_skill_list.xml",encoding='utf_8') as f:
    data=f.read()
    root = ET.fromstring(data)
    for padskil in root:
        if padskil:
            name = padskil.attrib["Name"]
            name = name.replace("-", "_")
            if (not name in PSEUDOFORECAST_PADDATA):
                PSEUDOFORECAST_PADDATA[name] = []
            PSEUDOFORECAST_PADDATA[name].append(skilltable(padskil, "PadSkill", scptype))
luadata.serialize(PSEUDOFORECAST_PADDATA, "padskills.lua")
with open("padskills.lua","a") as f:
    f.write("\nPSEUDOFORECASTPADSKILL_rawdata=data")