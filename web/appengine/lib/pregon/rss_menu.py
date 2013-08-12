# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from pregon.utils import get_today_date, get_date

def get_xml(args):

  header = u"""<?xml version="1.0" encoding="UTF-8" ?>
  <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" version="2.0">
  <channel>
   <title>PREGON - SIMURSS</title>
   <link>http://www.pregon.com.ar/</link>
   <description>El diario de Jujuy - Argentina</description>
   <copyright>2013, Pregon, todos los derechos reservados</copyright>
   <pubDate>Tue, 04 Sep 2012 20:20:18 GMT</pubDate>
   <image>
     <title>Pregon - RSS</title>
     <url>http://www.pregon.com.ar/img/LOGOPREGON.png</url>
     <link>http://www.pregon.com.ar</link>
   </image>
   <ttl>10</ttl>
   <atom:link href="http://www.pregon.com.ar/simu.rss" rel="self" type="application/rss+xml"/>

  """

  footer = u"""
   </channel>
  </rss>
  """

  output = StringIO.StringIO()
  output.write(header)

  link = "http://www.pregon.com.ar/"
  content = urlopen(link).read()
  soup = BeautifulSoup(content)

  today_date = get_today_date(soup)
  
  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(desc, url, guid):
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % desc )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % url )
    output_write( u'<guid isPermaLink="false">%s</guid>' % guid )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % get_date(today_date, '00:00') )
    output_write( u'<category>%s</category>' % desc )

    output_write( u'</item>')

  
  # Las urls son del tipo: ==> las que tienen 4/[nrp]/ppp.html son las cats
  # http://www.pregon.com.ar/subseccion/4/2/locales.html Locales
  for item in soup.select('ul#menudesplegable li ul li a'):
    url = item.attrs['href']
    cats = re.compile('\d+').findall(url)
    if cats is not None and len(cats) == 2 and cats[0] == u'4':
      put_item(item.text, url, cats[1])
    
  output.write(footer)

  return output.getvalue()