# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

from hashlib import sha1

import logging
import cgi
import re
import StringIO

from utils import read_clean
from xutils import get_datetime, get_date, get_header, get_footer

def get_xml(kwargs):
  
  output = StringIO.StringIO()
  output.write(get_header())

  link = u'http://www.diariocastellanos.net/Default.aspx'
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  
  soup = BeautifulSoup(content)
  
  date        = soup.select('#TopHeader #Fecha')
  today_date  = get_datetime(date)  

  def getOne(path):
    s = soup.select(path)
    if len(s):
      return s[0]
    return None

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def print_item(title, href):
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>')
    output_write( u'<link>%s</link>' % href )
    output_write( u'<guid isPermaLink="false">%s</guid>' % href.split('/')[-1:][0] )
    output_write( u'<pubDate>%s</pubDate>' % get_date('00:00', today_date))
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % title)
    output_write( u'</item>')
  
  def put_item(menu_item):
    
    title     = menu_item.select("a")[0].text
    href      = menu_item.select("a")[0]['href']
    print_item(title, href)
    
  
  print_item('Inicio', u'http://www.diariocastellanos.net/Default.aspx')
  
  selector  = u'#Header #Nav > ul > li'
  items     = soup.select(selector)
  for i in xrange(len(items)): 
    if i==0: # Home
      continue
    
    item=items[i]
    ul = item.select('ul')
    if ul is not None and len(ul)>0:
      lis = ul[0].select('li')
      for j in xrange(len(lis)): 
        li = lis[j]
        #print li.select("a")[0].text
        put_item(li)
    else:
      #print item.select("a")[0].text
      put_item(item)

  output.write(get_footer())

  return output.getvalue()