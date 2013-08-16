# -*- coding: utf-8 -*-

import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from ecosdiarios import xutils

header2 = u"""<?xml version="1.0" encoding="UTF-8" ?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/"
xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" version="2.0">
<channel>
 <title>EcosDiarios - SIMURSS</title>
 <link>http://www.ecosdiariosweb.com.ar/</link>
 <description>EcosDiarios - Necochea</description>
 <copyright>2013, EcosDiarios, todos los derechos reservados</copyright>
 <pubDate>%s</pubDate>
 <image>
   <title>EcosDiarios - RSS</title>
   <url>http://www.ecosdiariosweb.com.ar/</url>
   <link>http://www.ecosdiariosweb.com.ar/</link>
 </image>
 <ttl>10</ttl>
 <atom:link href="http://www.ecosdiariosweb.com.ar/simu.rss" rel="self" type="application/rss+xml"/>

"""

def get_xml(args):

  output = StringIO.StringIO()

  content = read_clean('http://www.ecosdiariosweb.com.ar/index.php?option=com_content&view=category&layout=blog&id=9&Itemid=13', args.get('inner_url'), use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)
  
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  parts = filter(lambda a: a!='de',soup.select('td.contentheading')[0].text.split())[1:]
  inx = months.index(parts[1].lower())
  today_date = xutils.get_date( datetime(int(parts[2]), inx+1, int(parts[0]) ), '00:00')

  output.write(header2 % today_date)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  tmp = soup.select('div#cke_pastebin')[0].text
  tmp = tmp.replace(u'\n\r',u'</br>')
  tmp = tmp.replace(u'\n',u'</br>')
  output_write( u'<item><![CDATA[%s]]></item>' % tmp )

  output.write(xutils.footer)

  return output.getvalue()