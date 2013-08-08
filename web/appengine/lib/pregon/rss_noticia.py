# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/
import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

def get_xml(args):

  today_date = ""

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

  link = 'http://www.pregon.com.ar/vernoticia.asp?id=%s' % args.get('host')
  content = urlopen(link).read()
  soup = BeautifulSoup(content)

  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.col1 strong')

  
  # 31 de Julio de 2013
  parts = ['fakeday'] + tmp[0].text.split('|')[0].strip().split()
  inx = months.index(parts[3].lower())  
  today_date = datetime(int(parts[5]), inx+1, int(parts[1]) )

  #soup.select('div.col1 strong')[0].text.split('|')[1].split()[0]

  def getDate(hhmm):
    parts = hhmm.split(':')
    tmp = today_date + timedelta(0,0,0,0,int(parts[1]),int(parts[0]))
    return tmp.strftime("%a, %d %b %Y %H:%M:%S")

  def getOne(path):
    s = soup.select(path)
    if len(s):
      return s[0]

    return None

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(realurl):
    
    category = getOne('h2.antetituloNormal')
    if category is None: 
      category = ''
    else:
      category = category.text

    hhmm = getOne('div.col1 strong')
    if hhmm is None: 
      hhmm = '00:00'
    else:
      hhmm = hhmm.text.split('|')[1].strip().split()[0]

    title = getOne('div.col1 h1.tituloAzulNota').text
    descr = getOne('div.col1 h3.bajada').text

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % realurl )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(realurl)[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % getDate(hhmm) )
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % category )


    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>' )
    
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % descr)

    content = getOne('div.col1 div.cc2 p')
    if content is not None: 
      content = content.text
    else:
      content = ''

    output_write( u'<news:content type="html" meta="contenido"><![CDATA[%s]]></news:content>' % content)

    img = getOne('div.contfotonota img')
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img.attrs['src'] )
    
    output_write( u'<media:text type="plain"></media:text>' )
    output_write( u'<media:credit role="publishing company">Pregon</media:credit>' )

    output_write( u'<media:text type="plain"></media:text>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  put_item(link)
    
  output.write(footer)

  return output.getvalue()