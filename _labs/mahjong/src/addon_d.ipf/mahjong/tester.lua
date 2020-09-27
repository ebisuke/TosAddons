package.path=package.path..';mahjong/src/addon_d.ipf/mahjong/?.lua'
math.randomseed(os.time())
local m=require('mgsys')
local hc=m.HandCalculator
local config=m.HandConfig()
local  tiles = m.TilesConverter.string_to_136_array('334450', '406', '45688',nil,true)
local hand =m.Hand()
hand.close=tiles
local result=hc.estimate_hand_value(hand.close,hand.close[7],nil,nil,config)
print("HOGE")


local board=m.Board()
board:startGame()
local player=board.members[1]
print(player.hand:__str__())

player:doDiscard(4)

for k,v in ipairs(board.members) do
    print(""..k..":"..v.hand:__str__().." SHANTEN:"..v:calculateShanten())
    local t=m.picker(v.hand.discards,nil,nil,function(x)return math.floor(x/4)end)
    print("discard:")
    for _,vv in ipairs(t) do
        print(""..vv)
    end

end
