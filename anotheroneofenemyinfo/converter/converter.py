import sys

sys.path.append('luadata')
import luadata

import xml.etree.ElementTree as ET
import io
import glob
import re

def pick(attr, name):
    if name in attr:
        return attr[name]
    else:
        return 0


GAMES = {}

filelist = glob.glob("E:/Analyze/newtos/extract/xml_minigame.ipf/*.xml")
for filename in filelist:
    with open(filename, encoding='utf_8') as f:
        data = f.read()

    root = ET.fromstring(data)

    for game in root:
        # if( skill.attrib["Name"].startswith("Mon_")):
        #    continue
        # if (skill.attrib["Name"].find(" ")!=-1 or skill.attrib["Name"].find("-")!=-1):
        #    continue

        name = game.attrib["Name"]

        #map = game.attrib['mapName']
        stages = {}
        objs = {}
        enemies = []
        triggers = []
        stagelist = game.find("StageList")
        if stagelist:

            for stage in stagelist:

                stagename = stage.attrib['Name']
                objlist = stage.find("ObjList")
                if objlist:
                    for obj in objlist:
                        if obj.attrib['Type'] == 'Monster' and 'objectKey' in obj.attrib:
                            print(stagename + str(int(obj.attrib['MonType'])))
                            enemies.append({
                                    'stagename':stagename,
                                    'type': int(obj.attrib['MonType']),
                                    'key': obj.attrib['objectKey']
                                })
            for stage in stagelist:
                stageevents = stage.find("StageEvents")
                if stageevents:
                    for event in stageevents:
                        if 'eventName' in event.attrib and event.attrib['eventName']!='end_check':
                            condlist = event.find("condList")
                            if condlist:

                                for toolscp in condlist:

                                    targetname = None
                                    targetid = None
                                    num = None
                                    sstr = None
                                    if toolscp and toolscp.attrib['Scp']=='MGAME_EVT_COND_MONHP':

                                        for scp in toolscp:
                                            if scp.tag == 'MGameObj' :
                                                _,targetname, targetid = re.findall(r'(/|)(.*?)/(\d*)', scp.attrib['List'])[0]

                                                if str.isdigit(targetid):
                                                    targetid = targetid
                                                else:
                                                    targetname=None
                                            if scp.tag == 'Num':
                                                num = scp.attrib['Num']
                                            if scp.tag == 'Str':
                                                sstr = scp.attrib['Str']
                                                break
                                        if targetname and num is not None:

                                            triggers.append({
                                                'threshold': int(num),
                                                'targetname': targetname,
                                                'targetid': targetid
                                            })

        # reshape

        for idx,en in enumerate(enemies):
            for t in triggers:
                if t["targetname"]==en["stagename"] and t["targetid"]==en["key"]:
                    if not en["type"] in  objs:
                        objs[en["type"]]=[]
                    objs[en["type"]].append(t["threshold"])
            if en["type"] in objs:
                oo=objs[en["type"]]
                #objs[en["type"]].sort(key=lambda x:x["threshold"])
                oo=sorted(oo)
                oo=sorted(set(oo),key=oo.index)
                objs[en["type"]]=oo
        GAMES[name] = {

            #'map': map,
            'objs': objs,

        }
luadata.serialize(GAMES, "aoe_games.lua")
with open("aoe_games.lua", "a") as f:
    f.write("\nANOTHERONEOFENEMYDATA_GAMES=data")
