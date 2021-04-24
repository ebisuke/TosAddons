# pseudortt
疑似的にRTT(ラウンドトリップタイム)を算出します

# 使い方
FPS表示を有効にするとFPSの下にRTTが表示されます。
# 注意点
通常ToSが行わない、サーバーに負荷を掛けるかもしれない処理をします。その点をご理解いただいた上でご使用ください。

# 仕様
app.RequestChannelTrafficsを呼んでからZONE_TRAFFICSメッセージが返ってくるまでの経過時間を計っています。  
上記が使えない場合は、session.inventory.ReqTrustPointを呼んでからUPDATE_TRUST_POINTメッセージが返ってくるまでの経過時間です。  
各種処理を含んだRTTとなりますため、あくまでも参考程度にしてください。

# リリースノート
* v0.0.1
初回公開