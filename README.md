# ご当地ベアbot(local_bear_bot)
ご当地ベア（ http://www.fujisey.co.jp/gotouchibear/ ）を愛してやまない人の通知用非公式botです。
 This is "an informal bot" for notification of local_baer . Made in local_bear lover.

## Botの場所
* twitter:`@bear_local`
* https://twitter.com/bear_local


## ツイートの意味
[ご当地ベア名]又は[ご当地ベア商品名,ショップ名] #[情報収集対象]

## やっていること
* 情報収集対象からご当地ベア情報を取得
* マスターファイルに存在しないものをツイート

## 情報収集対象
* rakuten api : 楽天apiの情報取得
        * https://webservice.rakuten.co.jp/document/
* 個人ブログさん：ルビのJewelBox
        * http://blog.livedoor.jp/scorpio11honey/archives/51341541.html

# 自分で動かしたい人向け
## インストール
1. 本スクリプトをclone
2. ${HOME}/.local/var/local_bear_bot/を作成し以下を入力
3. ${HOME}/.localbearbot.ymlを作成
	* RAKUTEN_APPID=""
		* 楽天アプリケーションID
	* TW_CONSUMER_KEY=""
		* Twitter CONSUMER_KEY
	* TW_CONSUMER_SECRET=""
		* Twitter CONSUMER_SECRET
	* TW_OAUTH_TOKEN=""
		* Twitter AUTH_TOKEN
	* TW_OAUTH_SECRET=""
		* Twitter AUTH_SECRET
	* TW_BOT_ADDSTR
		* ツイートの末尾につけることができる文字列です
3. 必要な場合、追加で以下もすること
	* export https_proxy=""
	* export http_proxy=""
4. 実行権限をつけてどーん

## 出来上がるファイル
* ${HOME}/.local/var/local_bear_bot/local_bear_bot.log
        * 動作ログです
* ${HOME}/.local/var/local_bear_bot/master.list
        * 検知した全てのクマさんの情報が格納されます

# 利用しているライブラリ
* json
* time
* re
* yaml
        * https://github.com/yaml/pyyaml
* requests
        * http://docs.python-requests.org/en/master/
* bs4
	* https://www.crummy.com/software/BeautifulSoup/
* pathlib
	* https://pathlib.readthedocs.io/en/pep428/
* twitter
	* http://mike.verdone.ca/twitter/
* logging
	* https://www.red-dove.com/python_logging.html
## License
MIT
