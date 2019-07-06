# unbuff2 reloaded
yyyyyu様のunbuffのrebuild対応版です。  
Supported Re:build.  

## default supported skills
But I did not confirm everything.
* levitation
* thurisaz
* genbuarmor
* reflectshield

## Original Unbuff Description
### 日本語


スキルの再使用でバフを解除するアドオン。

2chスレにあった[Unsummon](http://mint.2ch.net/test/read.cgi/ogame2/1477572608/798)を参考にして、レビテーションなどのスキルでも利用できるようにしたもの。
Unsummonと競合して動かないかも。未検証。

- 召喚中にサモニング再使用で解除
- レビテーション中にレビテーション再使用で解除
- トランスポーズ中にトランスポーズ再使用で解除 (既定では無効 - 後述のモード設定が必要)

#### チャットコマンド

- バフ解除 (モード設定は無視して常に解除)
	- `/unbuff <スキル名>`
		- &lt;スキル名&gt;: `summoning`, `levitation`, `transpose` のうちいずれか。
			スキル名は前方一致で良いため `sum` や `le` や `t` などでもOK
			- `summoning`: ソーサラーのサモニング
			- `levitation`: フェザーフットのレビテーション
			- `transpose`: ソーマタージュのトランスポーズ
- 任意のバフを解除 (モード設定は無視して常に解除)
	- `/unbuff <バフID>`
- モード設定 (各スキルについての有効/無効などの変更)
	- `/unbuff mode <モード> <スキル名>`
		- &lt;スキル名&gt;: `summoning`, `levitation`, `transpose` のうちいずれか。
			スキル名は前方一致で良いため `sum` や `le` や `t` などでもOK
		- &lt;モード&gt;: 0～2の数値を指定
			- 0: 無効
			- 1: バフがあるときは解除 (summoning, levitation の規定値)
			- 2: バフがあり、かつ、スキルCD中であれば解除
				スキルCD中でなければスキルを使用する。
		- 例1) `/unbuff mode 1 transpose`
		- 例2) `/unbuff mode 2 trans`
- 他にも同様のスキルがあれば http://twitter.com/y__y__u に以下を教えてください。
	- `/unbuff traceon` コマンド実行後にバフのある状態で該当スキルを使ってバフを付け、
		バフついた状態で同じスキルを実行(CD中でOK)すると。
		必要な情報(バフIDなど)がチャット欄に出力されるのでそれをください。
	- `/unbuff traceoff` を実行すれば上記の出力は止まります。



# リリースノート
## v2.1.0
* マジックシールドに対応
## v2.0.0
* Initial release
* クイックスロット操作を受け付けない問題を修正.  
Fixed the problem that quick slot operation was not accepted.  
