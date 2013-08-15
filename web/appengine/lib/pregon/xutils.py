# -*- coding: utf-8 -*-
from datetime import datetime, timedelta

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

def get_today_date(soup):
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.clima div')

  # 31 de Julio de 2013
  parts = tmp[len(tmp)-1].text.split()
  while 'de' in parts: parts.remove('de')
  if len(parts) > 3: parts = parts[-3:]

  inx = months.index(parts[1].lower())
  return datetime(int(parts[2]), inx+1, int(parts[0]) )

def get_date(today_date, hhmm):
  parts = hhmm.split(':')
  tmp = today_date + timedelta(0,0,0,0,int(parts[1]),int(parts[0]))
  return tmp.strftime("%a, %d %b %Y %H:%M:%S")

def get_one(soup, path):
  s = soup.select(path)
  if len(s):
    return s[0]

  return None
