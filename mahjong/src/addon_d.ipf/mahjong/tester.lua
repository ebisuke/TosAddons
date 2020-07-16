package.path=package.path..';mahjong/src/addon_d.ipf/mahjong/?.lua'

local m=require('mgsys')
local hc=m.HandCalculator
local config=m.HandConfig()
local tiles = m.TilesConverter.string_to_136_array('22444', '333567', '444')
local hand =m.Hand()
hand.close=tiles
local result=hc.estimate_hand_value(hand.close,hand.close[1],nil,nil,config)
print("HOGE")