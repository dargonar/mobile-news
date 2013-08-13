# -*- coding: utf-8 -*-

import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

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

  link = 'http://www.pregon.com.ar/subseccion/4/%s/dummy.html' % args.get('host')
  content = urlopen(link).read()
  
  #HACKO --- limpiar HTML
  from lxml import etree
  parser = etree.HTMLParser()
  tree   = etree.parse(StringIO.StringIO(content), parser)
  content = etree.tostring(tree.getroot(), pretty_print=True, method="html")
  #HACKO --- limpiar HTML

  soup = BeautifulSoup(content)

  global_cat = soup.select('h1.antetituloNormal')[0].text.split()[2]

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(div):

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % div.h1.text )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % div.a['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(div.a['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate></pubDate>' )
    output_write( u'<author></author>' )
    
    cat = div.h2
    if cat is not None:
      cat = div.h2.text
    else:
      cat = ''

    output_write( u'<category>%s</category>' % global_cat )


    output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % global_cat )
    output_write( u'<news:subheader type="plain" meta="bajada"><![CDATA[%s]]></news:subheader>' % div.p.text )

    img = div.img
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
    
    output_write( u'<media:text type="plain"></media:text>' )
    output_write( u'<media:credit role="publishing company">Pregon</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )
    output_write( u'</item>')

  divs=soup.select('div.contLineaTitulo')
  for div in divs:
    put_item(div)

  output.write(footer)

  return output.getvalue()