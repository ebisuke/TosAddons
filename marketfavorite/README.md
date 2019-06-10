# marketfavorite
マーケットにあるアイテムをお気に入り登録し、あとから検索できるアドオンです

## 設定方法
マーケット上部に「お気に入り」ボタンが出ますのでそれをクリックすると、お気に入り登録・検索画面が表示されます。  
マーケット及びインベントリからのドラッグアンドドロップでアイテムを登録します。  
右クリックで検索します。
Shift+右クリックで登録を解除します  

## 制約
* 名前検索ですので、その名前が含まれる他のアイテムもヒットすることがあります。
* マーケットを閉じでもお気に入り登録・検索画面は表示されたままにしておりますが、マーケット及びインベントリ以外からのアイテム登録はできません。
* 文字数の制限があるようなので、アイテム名が長い場合末尾を削っております。
  
## 謝辞
実装にあたり Alimov Stepan様、Kyle Smith様のutf8.luaを使用しております。  
ここに感謝の意を示します。
https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862
# 既知の問題 
ITOSにてアイテムを右クリックしても反応せず、次のアイテムを右クリックすると前のアイテムが表示される。  
If you right-click an item in ITOS, it does not displayed, and if you right-click the next item, the previous item is displayed.  
# リリースノート
## v1.1.0
英語対応。 supported multiligal(EN,JP).  
ITOS向けバグフィックス。 Bugfix in ITOS environment.

## v1.0.0
初回