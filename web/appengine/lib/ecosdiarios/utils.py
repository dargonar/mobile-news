# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from lxml import etree
from urllib2 import urlopen
from StringIO import StringIO

link = "http://www.ecosdiariosweb.com.ar/"

header = u"""<?xml version="1.0" encoding="UTF-8" ?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/"
xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" version="2.0">
<channel>
 <title>EcosDiarios - SIMURSS</title>
 <link>http://www.ecosdiariosweb.com.ar/</link>
 <description>EcosDiarios - Necochea</description>
 <copyright>2013, EcosDiarios, todos los derechos reservados</copyright>
 <pubDate>Tue, 04 Sep 2012 20:20:18 GMT</pubDate>
 <image>
   <title>EcosDiarios - RSS</title>
   <url>http://www.ecosdiariosweb.com.ar/</url>
   <link>http://www.ecosdiariosweb.com.ar/</link>
 </image>
 <ttl>10</ttl>
 <atom:link href="http://www.ecosdiariosweb.com.ar/simu.rss" rel="self" type="application/rss+xml"/>

"""

footer = u"""
 </channel>
</rss>
"""

def get_today_date(soup):
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div#top_menu p')

  # Necochea, domingo 11 de agosto 2013
  parts = tmp[len(tmp)-1].text.split(',')[-1].split()
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

def read_clean(url):
  content = urlopen(url, timeout=15).read()  
  parser = etree.HTMLParser()
  tree   = etree.parse(StringIO(content), parser)
  content = etree.tostring(tree.getroot(), pretty_print=True, method="html")
  return content
  
