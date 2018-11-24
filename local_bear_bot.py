#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import yaml
import requests
import json
from time import sleep
from bs4 import BeautifulSoup
import re
from pathlib import Path
import twitter
import logging
def setLogging(_debug=False):
    formatter = logging.Formatter('[%(asctime)s][%(levelname)s]%(message)s')
    fh=logging.FileHandler(_PATH_LOG)
    sh=logging.StreamHandler()
    logger = logging.getLogger('LBB')
    logger.setLevel(10)
    logger.addHandler(fh)
    fh.setFormatter(formatter)
    if _debug:
        logger.addHandler(sh)
        sh.setFormatter(formatter)
    return logger
class RAKUTEN():
    __Applicationid=""
    __Kw=""
    __RAKUTEN_URL="https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706"
    __LOG_STR="[RAKUTEN]"
    def __init__(self,_id,_kw=""):
        _Log.info(self.__LOG_STR+"start Rakutenapi")
        self.__setApplicationid(_id)
        self.setKeyword(_kw)
    def setKeyword(self,_kw):
        _Log.info(self.__LOG_STR+"set search keyword")
        self.__Kw = _kw
    def __setApplicationid(self,_id):
        _Log.info(self.__LOG_STR+"set application id")
        self.__Applicationid = _id
    def getApplicationid():
        return self.__Applicationid
    def getBearList(self):
        _Log.info(self.__LOG_STR+"get data Start")
        _result=[]
        _r = json.loads((requests.get(self.__RAKUTEN_URL,self.makeParamator())).text)
        exit
        for _row in _r['Items']:
            _result.extend((_row['Item']['itemName']+","+_row['Item']['shopName']+" #rakuten_api").splitlines())
        _Log.info(self.__LOG_STR+"MaxPage:"+str(_r['pageCount']))
        _n=self.getNextPage(_r['page'])
        while _n<=_r['pageCount']:
            sleep(1)
            for _row in json.loads((requests.get(self.__RAKUTEN_URL,self.makeParamator(_n))).text)['Items']:
                _result.extend((_row['Item']['itemName']+","+_row['Item']['shopName']+" #rakuten_api").splitlines())
            _n = self.getNextPage(_n)
        _Log.info(self.__LOG_STR+"get data Done")
        return _result
    def getNextPage(self,_page=1):
        _Log.info(self.__LOG_STR+"Next Index : "+str(_page+1))
        return _page+1
    def makeParamator(self,_page=1):
        _Log.info(self.__LOG_STR+"make get parametar ."+str(_page))
        return {'applicationId':self.__Applicationid,'keyword':self.__Kw,'page':_page}
class RubiBlog():
    __Kw=""
    __Urls=[]
    __LOG_STR="[RUBI]"
    def __init__(self,_kw,_urls):
        _Log.info(self.__LOG_STR+"start ribi")
        self.setKeyword(_kw)
        self.setUrls(_urls)
    def setKeyword(self,_kw):
        _Log.info(self.__LOG_STR+"set keyword")
        self.__kw=_kw
    def setUrls(self,_urls):
        _Log.info(self.__LOG_STR+"set urls")
        self.__Urls=_urls
    def getBearList(self):
        _result=[]
        for _row in self.__Urls:
            _result.extend([s for s in self.getUrlData(_row).splitlines() if self.__kw in s])
            _Log.info(self.__LOG_STR+"added url data")
        return _result
    def getUrlData(self,_url):
        _Log.info(self.__LOG_STR+"get urldata:"+_url)
        _textbody = str((BeautifulSoup((requests.get(_url)).text,'lxml')).find_all("div", attrs={"class": "article-body-inner"})[0])
        return re.sub("<.*"," #rubi_blog",re.sub("・","\r\n",re.sub("●","\r\n",_textbody)))
class OfficalFujiseySan():
    __Kw=""
    __Url="http://www.fujisey.co.jp/gotouchibear/"
    __LOG_STR="[FUJISEY]"
    __HashTag="#Fujisay_Offical"

    def __init__(self):
        _Log.info(self.__LOG_STR+"start fujisey-san")

    def getBearList(self):
        _result=[]
        for row in self.getUrlData():
            _lnk=row.get('href')
            _name=BeautifulSoup(str(row.find('em')),'lxml').text
            _result.extend([_name + " " + self.__HashTag + " " + _lnk])
        return _result

    def getUrlData(self):
        _Log.info(self.__LOG_STR+"get url data:"+self.__Url)
        return (BeautifulSoup((requests.get(self.__Url)).text,'lxml')).find_all("a", attrs={"class": "a-item"})

def loadYaml(_path):
    global _Log
    global _Config
    _Log.info("config file path:"+_path)
    try:
        _Config=yaml.load(open(_path, "r+"))
        _Log.info("config file  read success")
        return True
    except:
        _Log.warning("config file read failed")
        return False
def checkNewBear(_master_file,_bear_list):
    _Log.info("new bear check start")
    _master_list=_master_file.readlines()
    for _row in _bear_list:
        if not _row+"\n" in _master_list:
            if sayTw(_row+" "+_Config['TW_BOT_ADDSTR']):
                addMaster(_row,_master_file,_master_list)
    _Log.info("new bear check end")
    _master_file.close()
def addMaster(_bearname,_f,_l):
    _Log.info("Find new bear_data!! :"+_bearname)
    _l.extend(_bearname+"\n")
    _f.write(_bearname+"\n")

def makeTwAuth():
    global _TwObj
    _Log.info("make Twitter Auth")
    try:
        _TwObj=twitter.Twitter(auth=twitter.OAuth(_Config['TW_OAUTH_TOKEN'], _Config['TW_OAUTH_SECRET'], _Config['TW_CONSUMER_KEY'], _Config['TW_CONSUMER_SECRET']))
        _Log.info("success")
        return True
    except:
        _Log.warning("cant made twitter auth")
        return False

def sayTw(_str=""):
    global _TwObj
    _Log.info("sayTwert:"+_str)
    try:
        _TwObj.statuses.update(status=_str)
        _Log.info("tweet success....sleep 2")
        sleep(2)
        return True
    except:
        _Log.warning("tweet faled")
        return False

RAKUTEN_KEYWORD="ご当地ベア"
RUBI_KEYWORD="ベア"
RUBI_URLS=[
        "http://blog.livedoor.jp/scorpio11honey/archives/51341541.html",
        "http://blog.livedoor.jp/scorpio11honey/archives/49909061.html",
        ]
_PATH_CONFIG=str(Path.home())+"/.localbearbot.yml"
_PATH_LOG=str(Path.home())+"/.local/var/local_bear_bot/local_bear_bot.log"
_PATH_MASTER=str(Path.home())+"/.local/var/local_bear_bot/master.list"
_Debug=False
_TwObj=""
_Log=setLogging(_Debug)
if __name__ == '__main__':
    _Log.info("StartMain")
    if not loadYaml(_PATH_CONFIG) or not makeTwAuth():
        exit()
    _now_bears=[]
    _now_bears.extend(RAKUTEN(_Config['RAKUTEN_ID'],RAKUTEN_KEYWORD).getBearList())
    _now_bears.extend(RubiBlog(RUBI_KEYWORD,RUBI_URLS).getBearList())
    _now_bears.extend(OfficalFujiseySan().getBearList())
    checkNewBear(open(_PATH_MASTER, 'r+'),_now_bears)
    _Log.info("EndMain")
