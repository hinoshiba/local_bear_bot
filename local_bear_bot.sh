#!/bin/bash
debug_flg=0

## There is a need to create a configuration file
# touch ${HOME}/.local_bear_bot.conf
# vim ${HOME}/.local_bear_bot.conf
###  RAKUTEN_APPID="xxxxxxxxxxxxxxxxxx"
###  CONSUMER_KEY="xxxxxxxxxxxxxx"
###  CONSUMER_SECRET="xxxxxxxxxxx"
###  OAUTH_TOKEN="xxxxxxxxxxxxxx"
###  OAUTH_SECRET="xxxxxxxxxxxx"
###  # if you need
###  export http_proxy=
###  export https_proxy=
###  export ftp_proxy=


##### root config
## any
SCRIPT_NAME="local_bear_bot"
PATH_CONFIG="${HOME}/.${SCRIPT_NAME}.conf"
source ${PATH_CONFIG}
SEARCH_WORD="%E3%81%94%E5%BD%93%E5%9C%B0%E3%83%99%E3%82%A2"
DEBUG_FLG_CODE=1
DEBUG_SEVERITY="DEBUG"


##### user config
PATH_WORK="./"

## rakuten
RAKUTEN_API="https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706"
RAKUTEN_FLG="#rakuten_api"

## twitter
TWITTER_API_VER=1.1
SUCCESS_WORD="created_at"
BEAR_TAG="#ご当地ベア"


#### Conts
PATH_TMP="${PATH_WORK}${SCRIPT_NAME}.tmp"
PATH_LIST="${PATH_WORK}${SCRIPT_NAME}.list"
PATH_LOG="${PATH_WORK}${SCRIPT_NAME}.log"
PATH_MASTER="${PATH_WORKP}${SCRIPT_NAME}_MASTER.list"
PATH_ERROR="${PATH_WORKP}${SCRIPT_NAME}_ERROR.list"

#### function
function checkEmpty(){
	local target="$1"
	local target_name=$2
	if [ -z "${target}" ]; then
		echoLog "ERROR" "empty ${target}:${target_name}"
		exit 1
	fi
}
function echoLog(){
	local severity=$1
	local message=$2
	local date_message=`date +"%Y-%m-%d %H:%M:%S"` 
	if [ ${severity} != ${DEBUG_SEVERITY} ]; then
		echo "[${date_message}][${severity}] ${message}" >> ${PATH_LOG}
	else
		if [ ${debug_flg} -eq ${DEBUG_FLG_CODE} ]; then
			echo "[${date_message}][${severity}] ${message}" >> ${PATH_LOG}
			echo "[${date_message}][${severity}] ${message}" 
		fi
	fi
}
function sayTweet(){
	local message="$1"
	checkEmpty "${message}"
	message_encode=`echo -n "${message}"|nkf -WwMQ |sed -e ':loop; N; $!b loop; s/\n//g' | tr = % | sed -E "s/%+/%/g" | sed -e "s/%5F/_/g" | sed -e "s/%2E/\./g"|sed -e "s/%$//g"`
	message_string=`echo -n "${message_encode}" | sed -e "s/%/%25/g"`
	message_curl=`echo -n "${message_encode}"`
	timestamp=`date +%s`
	nonce=`date +%s%T | openssl base64 | sed -e s'/[+=/]//g'`
	signature_base_string="POST&https%3A%2F%2Fapi.twitter.com%2F${TWITTER_API_VER}%2Fstatuses%2Fupdate.json&oauth_consumer_key%3D${CONSUMER_KEY}%26oauth_nonce%3D${nonce}%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D${timestamp}%26oauth_token%3D${OAUTH_TOKEN}%26oauth_version%3D1.0%26status%3D${message_string}"
	signature_key="${CONSUMER_SECRET}&${OAUTH_SECRET}"
	oauth_signature=`echo -n ${signature_base_string} | openssl dgst -sha1 -hmac ${signature_key} -binary | openssl base64 | sed -e s'/+/%2B/g' -e s'/\//%2F/g' -e s'/=/%3D/g'`
	header="Authorization: OAuth oauth_consumer_key=\"${CONSUMER_KEY}\", oauth_nonce=\"${nonce}\",oauth_signature=\"${oauth_signature}\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"${timestamp}\",oauth_token=\"${OAUTH_TOKEN}\", oauth_version=\"1.0\""
	result=`curl -X POST "https://api.twitter.com/${TWITTER_API_VER}/statuses/update.json" -d "status=${message_curl}" -H "Content-Type: application/x-www-form-urlencoded" -H "${header}" -s`
	result_code=`echo "${result}" | fold -w 140 | head -n 1 | awk -F \" '{print $2","$10}'`
	sleep 5
	if echo "${result_code}" | grep ${SUCCESS_WORD} > /dev/null ; then
		echoLog "INFO" "TWEET:${result_code}"
		echoLog "INFO" "COUNT:${#message}"
		echo 0
	else
		echoLog "ERROR" "TWEET:${result}"
		echoLog "ERROR" "COUNT:${#message}"
		echoLog "ERROR" "ORGIN_MSG:${message}"
		echoLog "ERROR" "URLENCODE_MSG:${message_string}"
		echoLog "ERROR" "CURLURLENCODE_MSG:${message_curl}"
		echo 1
	fi
}
##### main
echoLog "INFO" "START Script"
if [ ! -e ${PATH_MASTER} ] ; then 
	touch ${PATH_MASTER}
fi
if [ ! -e ${PATH_CONFIG} ] ; then 
	echoLog "ERROR" "Need to create a configurationi file"
	exit 1
fi
#### rakuten
echo "" > ${PATH_TMP}
echo "" > ${PATH_LIST}
echoLog "INFO" "Rakuten DL start"
curl -s "${RAKUTEN_API}?applicationId=${RAKUTEN_APPID}&keyword=${SEARCH_WORD}&format=xml" |grep -e "itemName" -e "shopName" -e "pageCount" > ${PATH_TMP}
if [ $? -ne 0 ]; then
	echoLog "ERROR" "Rakuten DL Error"
	exit 1
else
	echoLog "DEBUG" "Add list 1"
	cat ${PATH_TMP} | grep -v "<pageCount>" |sed -e ':loop;N;$!b loop;s/<\/itemName>\n//g'| sed "s/\ *<shopName>/\ \/\ /g" | sed -r "s/^.*>(.*)<.*$/\1/g"| sed -e "s/$/\ ${RAKUTEN_FLG}/g" >> ${PATH_LIST}
fi
page=`cat ${PATH_TMP} | head -n 1 | sed -r "s/^.*>([0-9]+)<.*$/\1/"`
checkEmpty ${page}
for((page_cnt=2;page_cnt<=$page;page_cnt++));do
	sleep 1 
	curl -s "${RAKUTEN_API}?applicationId=${RAKUTEN_APPID}&keyword=${SEARCH_WORD}&format=xml&page=${page_cnt}" | grep -e "itemName" -e "shopName" > ${PATH_TMP}
	if [ $? -ne 0 ]; then
		echoLog "ERROR" "Rakuten DL Error:${page_cnt}"
	else
		echoLog "DEBUG" "Add list ${page_cnt}"
		cat ${PATH_TMP} | sed -e ':loop;N;$!b loop;s/<\/itemName>\n//g'| sed "s/\ *<shopName>/\ \/\ /g" | sed -r "s/^.*>(.*)<.*$/\1/g" | sed -e "s/$/\ ${RAKUTEN_FLG}/g" >> ${PATH_LIST}
	fi
done
rm ${PATH_TMP}
echoLog "INFO" "Rakuten DL End"

## line check
cat ${PATH_LIST} | while read line
do
	if grep "${line}" ${PATH_MASTER} > /dev/null ; then
		echoLog "DEBUG" "No Tweet"
	else
		echoLog "DEBUG" "Tweet"
		if [ 0 -eq `sayTweet "${line} ${BEAR_TAG}"` ] ; then
			echoLog "DEBUG" "AddList"
			echoLog "DEBUG" "DATA:${line}"
			echo "${line}" >> ${PATH_MASTER}
		else
			echoLog "DEBUG" "NotAddList"
			echo "${line}" >> ${PATH_ERROR}
		fi
	fi
done
rm ${PATH_LIST}
