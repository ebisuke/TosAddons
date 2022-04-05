# Ebiremovedialog
各種確認ダイアログを削除します。
拙作3アドオンの上位互換です。競合しますので本アドオン導入後は旧アドオンは削除ください。
# 使用方法
白チャットで`/erdc`と入力すると設定画面が表示されます。  
それぞれの項目は以下の通りとなります。  
設定はToS再起動後に反映されます。  
- Remove dialog of entering in challengemode
ONにするとチャレンジモード入場時の確認ダイアログを削除（自動処理）します。
- Remove dialog of entering in challenge hardmode 
ONにすると次元チャレンジモード入場時の確認ダイアログを削除（自動処理）します。
- Remove dialog of going to next level in challengemode
ONにするとチャレンジモードの次のレベルへ入場するときの確認ダイアログを削除（自動処理）します。
- Remove dialog of complete challengemode
ONにするとチャレンジモード終了時（中断時ではありません）の確認ダイアログを削除（自動処理）します。
- Remove dialog of abort challengemode
ONにするとチャレンジモード中断時の確認ダイアログを削除（自動処理）します。
- Remove dialog of reading a monster cardbook
ONにするとモンスターカードブック使用時の確認ダイアログを削除します。
- Remove dialog of timelimited item in storage.
ONにすると期間限定アイテムをチーム倉庫に入れた時の確認ダイアログを削除します。  
副作用として、アイテム入庫時のNew表示がなくなります。
- Remove dialog of using dimension ticket.
ONにすると次元崩壊点入場券使用時の確認ダイアログを削除します。  
- Remove dialog of using instance dungeon ticket.
ONにするとインスタンスダンジョン入場券使用時の確認ダイアログを削除します。  
- Remove confirmation dialog of Gold Roupe.And keep selected item.
職人のルーペを使用したときに確認ダイアログを表示しないようにします。また、鑑定後設定したアイテムが消えず保持するようにします。
- Remove confirmation dialog when removing a relic gem.
ONにするとレリックジェム抽出時の確認ダイアログを削除します。  
- Remove confirmation dialog when installing a relic gem.
ONにするとレリックジェム装着時の確認ダイアログを削除します。  

# 注意点
* 変更は即時ではなく、再起動後に反映されます。ただし、マップ変更だけで反映される場合もあります。

# リリースノート
## v0.4.1
レリックジェム装着時の確認ダイアログ削除機能追加
## v0.4.0
レリックジェム抽出時の確認ダイアログ削除機能追加
## v0.3.0
* 銀ルーペ時の確認削除
## v0.2.1
* 保存時にスタックオーバーフローになる問題を修正
## v0.2.0
* 金ルーペ使用時の確認ダイアログ削除機能追加
## v0.1.4
* 強制的にchallenge_modeフレームを消したり付けたりする機能追加
* ダイアログがないのにクリックしようとしている箇所を削除
## v0.1.0
* EP13対応
## v0.0.3
* 注意書き変更
## v0.0.2 
* バグ修正
## v0.0.1
初回
