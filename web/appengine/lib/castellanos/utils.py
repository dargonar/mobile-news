# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from datetime import datetime, timedelta


def get_datetime(soup_element):  
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  
  soup_element[0].strong.decompose()
  parts  = soup_element[0].text.split()
  # Lunes 05 Agosto 2013
  return datetime(int(parts[3]), months.index(parts[2].lower())+1, int(parts[1]) )

def get_date(hhmm, today_date):
  parts = hhmm.split(':')
  if len(parts)<2:
    parts = [0,0]
  tmp = today_date + timedelta(0,0,0,0,int(parts[1]),int(parts[0]))
  return tmp.strftime("%a, %d %b %Y %H:%M:%S")

def get_header():
  return u"""<?xml version="1.0" encoding="UTF-8" ?>
  <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" version="2.0">
  <channel>
   <title>DIARIO CASTELLANOS</title>
   <link>http://www.diariocastellanos.net/</link>
   <description>El diario de Rafaela, Argentina - Con la verdad no ofendo ni temo</description>
   <copyright>2013, Editora del Centro, Propiedad Intelectual N84.363, todos los derechos reservados</copyright>
   <pubDate>Tue, 04 Sep 2012 20:20:18 GMT</pubDate>
   <image>
     <title>DiarioCastellanos - RSS</title>
     <url>http://www.diariocastellanos.net/images/header/castellanos.png</url>
     <link>http://www.diariocastellanos.net</link>
   </image>
   <ttl>10</ttl>
   <atom:link href="http://www.diariocastellanos.net/simu.rss" rel="self  " type="application/rss+xml"/>

  """

def get_footer():
  u"""
   </channel>
  </rss>
  """