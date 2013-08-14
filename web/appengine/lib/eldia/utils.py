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


def get_header():
  return u"""<?xml version="1.0" encoding="UTF-8" ?>
  <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" version="2.0">
  <channel>
    <title>Diario El Día - RSS</title>
    <link>http://www.eldia.com.ar</link>
    <description>Noticias de La Plata - Argentina</description>
    <copyright>
    (c) 2007, Diario El Día, todos los derechos reservados
    </copyright>
    <pubDate>Wed, 14 Aug 2013 03:00:01 -0300</pubDate>
    <image>
    <title>Diario El Día - RSS</title>
    <url>http://www.eldia.com.ar/imag/logo_mini.jpg</url>
    <link>http://www.eldia.com.ar</link>
    </image>
    <ttl>10</ttl>
    <atom:link href="http://www.eldia.com.ar/rss/index.aspx" rel="self" type="application/rss+xml"/>
  """

def get_footer():
  return u"""
   </channel>
  </rss>
  """