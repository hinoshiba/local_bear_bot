# ご当地ベアbot(local_bear_bot)
ご当地ベア（ http://www.fujisey.co.jp/gotouchibear/ ）を愛してやまない人の通知用非公式botです。
 This is "an informal bot" for notification of local_baer . Made in local_bear lover.

## Botの場所
* twitter:`@bear_local`
* https://twitter.com/bear_local


## ツイートの意味
[ご当地ベア名]又は[ご当地ベア商品名/ショップ名] #[情報収集対象]

## やっていること
* 情報収集対象からご当地ベア情報を取得
* マスターファイルに存在しないものをツイート

## 情報収集対象
* rakuten_api : 楽天apiの情報取得

# 自分で動かしたい人向け
# インストール
1. 本スクリプトをclone
2. ${HOME}/.local_bear_bot.conf　を作成し以下を入力
	* RAKUTEN_APPID=""
		* 楽天アプリケーションID
	* CONSUMER_KEY=""
		* Twitter CONSUMER_KEY
	* CONSUMER_SECRET=""
		* Twitter CONSUMER_SECRET
	* OAUTH_TOKEN=""
		* Twitter AUTH_TOKEN
	* OAUTH_SECRET=""
		* Twitter AUTH_SECRET
3. 必要な場合、追加で以下も入力
	* export https_proxy=""
4. 実行権限をつけてどーん

## 出来上がるファイル
* local_bear_bot.list
	* 一時ファイルです。勝手に消えるので、気にしないでください。
* local_bear_bot.tmp
	* 一時ファイルです。勝手に消えるので、気にしないでください。
* local_bear_bot.log
	* ログファイルです。みてやってください。 
* local_bear_bot_ERROR.list
	* マスターファイル。ツイート済みのキーワードが格納されます。
* local_bear_bot_MASTER.list
	* エラーファイル。ツイートエラーになったキーワードが保存されます。開発時のエラー確認用に役立てています。


