# -*- coding: utf-8 -*-

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

def get_xml(args):
  
  output = StringIO.StringIO()
  output.write(get_header())

  link = u'http://www.diariocastellanos.net/funebres.aspx'
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

  def get_page_and_print_items(link):
    content = urlopen(link).read()
    _soup = BeautifulSoup(content)

    selector  = u'#Content .ColumnaAB .NotaHead'
    item     = _soup.select(selector)
    time = item[0].select('p .Time')[0].text
    title = '%s %s' % (item[0].select('h2')[0].text, time if ':' not in time else '') #.select('span')[0]
    
    avisos    = _soup.select(u'#Content .ColumnaAB .Nota .NotaData')
    for tag in _soup():
      for attribute in ["class", "id", "name", "style"]:
        del tag[attribute]
   
    my_content=''
    for _content in avisos[0].contents:
      if isinstance(_content, Tag):
        my_content = my_content + _content.prettify().replace(u'<o:p></o:p>', '')
    
    print_item(title, my_content, link)
  
  def __get_page_and_print_items(link):
    
    # diferentes ->
    #   http://www.diariocastellanos.net/24983-Avisos-Funebres.note.aspx
    #   http://www.diariocastellanos.net/25024-Avisos-Funebres.note.aspx
    #   http://www.diariocastellanos.net/24697-Avisos-Funebres.note.aspx
    content = urlopen(link).read()
    _soup = BeautifulSoup(content)

    selector  = u'#Content .ColumnaAB .Nota .NotaData p'
    items     = _soup.select(selector)
    
    step = 3 if len(items)>3 and items[3].contents!='<o:p>&nbsp;</o:p>' else 4
    
    # logging.error('------')
    # logging.error('%s %s' % (link, str(step)))
    # logging.error('------')
    for i in range(0, len(items)-1, step): 
      if len(items) < i+2+1:
        break
      name = items[i]
      qepd = items[i+1]
      
      title = '%s %s' % (name.text, qepd.text) #.select('span')[0]
      description = items[i+2].text
      
      print_item(title, description, link)
      
  def print_item(title, description, link):
    output_write( u'<item>')
    output_write( u'<title><![CDATA[%s]]></title>' % title )
    output_write( u'<description><![CDATA[%s]]></description>' % description if description is not None and len(description)>0 else '<![CDATA[&nbsp;]]>')
    output_write( u'<link>%s</link>' % link )
    output_write( u'<guid isPermaLink="false">%s</guid>' % link )
    output_write( u'<pubDate>%s</pubDate>' % get_date('00:00', today_date))
    output_write( u'<category><![CDATA[%s]]></category>' % title)
    output_write( u'</item>')
  
  #get_page_and_print_items
  
  selector  = u'#Content .ColumnaAB .Noticia .Data h2 a'
  item      = soup.select(selector)
  get_page_and_print_items(item[0]['href'])
  
  selector  = u'#Content .ColumnaAB .Noticia h3 a'
  items     = soup.select(selector)
  for i in xrange(len(items)): 
    get_page_and_print_items(items[i]['href'])
  
  output.write(get_footer())

  return output.getvalue()