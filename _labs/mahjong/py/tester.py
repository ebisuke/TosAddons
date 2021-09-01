from mahjong.tile import TilesConverter
from mahjong.hand_calculating.hand import HandCalculator

hc=HandCalculator()
tc=TilesConverter()

tiles=tc.string_to_136_array('22444', '333567', '444')
result=hc.estimate_hand_value(tiles,tiles[0],None,None,None)
print(result)