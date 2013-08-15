# -*- coding: utf-8 -*-
#http://www.ecosdiariosweb.com.ar/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from ecosdiarios import xutils

def get_xml(args):

  output = StringIO.StringIO()
  output.write(xutils.header)

  soup = BeautifulSoup(read_clean(xutils.link, args.get('inner_url'), use_cache=args.get('use_cache')))
  today_date = xutils.get_today_date(soup)
  
  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(desc, url, guid):
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % desc )
    output_write( u'<description></description>' )
    output_write( u'<link><![CDATA[%s]]></link>' % url )
    output_write( u'<guid isPermaLink="false">%s</guid>' % guid )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % xutils.get_date(today_date, '00:00') )
    output_write( u'<category>%s</category>' % desc )

    output_write( u'</item>')


  for item in soup.select('div#nav ul')[0].find_all('li')[1].ul.find_all('li'):
    desc = item.a.text
    url  = item.a['href']
    guid = re.compile('&id=(\d+)').findall(url)[0]

    put_item(desc, url, guid)
    
  output.write(xutils.footer)

  return output.getvalue()