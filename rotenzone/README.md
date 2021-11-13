# rotenzone
露天を建てられない領域を参考として表示します

# 使い方
LSHIFTを押しっぱなしにすると、今の位置で露天を建てられない場合にプレイヤーがエリートモンスターのように赤く光り、かつ干渉しているNPCの領域を赤い円で表示します。  
LSHIFT+LALTを押しっぱなしにすると、周囲の露天を建てられそうにない領域を赤い円で表示します。

NPCと干渉しているか判定する距離は基本５０です。  
スクワイアを履修している場合、キャンプ時の判定距離７０ではなく通常露天の５０で判定します。    
そのため、キャンプ露天の場合は本アドオンで赤く表示されていない場合でも露天を建てられないときがあります。  
アルケミストを履修している場合、通常露天の５０ではなく、覚醒露天の６０で判定します。    
そのため、ジェムロースト露天の場合は本アドオンで赤く表示されている場合でも露天を建てられるときがあります。  
  
なお、NPCからの距離以外の要素で建てられるかどうかの確認は本アドオンはしていません。

判定距離はハードコーディングしていますので、ToSバージョンアップにより利用不可能になる場合があります。

# リリースノート
## v0.0.1
初回