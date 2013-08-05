# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

def get_xml():

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

  link = "http://www.pregon.com.ar/"
  content = urlopen(link).read()
  #fp = open('pregon.html', 'w')
  #fp.write(content) 
  #fp.close()
  soup = BeautifulSoup(content)
  #soup = BeautifulSoup(open('pregon.html','r').read())

  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.clima div')

  # 31 de Julio de 2013
  parts = tmp[len(tmp)-1].text.split()
  inx = months.index(parts[3].lower())
  today_date = datetime(int(parts[5]), inx+1, int(parts[1]) )

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

  def get_main():
    title = getOne("div.destacadasbox100 h1.box100-titulo a")
    if title is None: return None

    desc = getOne("div.destacadasbox100 p")
    if desc is None: return None

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate></pubDate>' )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )

    lead = getOne("div.destacadasbox100 h2.box100-antetitulo")
    if lead is not None:
      output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead.text )
    
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' desc.text )

    img = getOne("div.destacadasbox100 div.box100-foto img")
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Pregon</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  def put_item(title, box):

    spans = box.p.find_all('span')

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % getDate(spans[0].strong.text) )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )


    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>' )
    
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % spans[1].text )

    img = box.div.img
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Pregon</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  # box = soup.select('div.C1 div.box')
  # for i in xrange(len(box)):
  #   #box[i].p.span.next_sibling
  #   print box[i].p.find_all('span')
  #   #print x.unicode()

  get_main()

  h1 = soup.select('div.C1 h1 a')
  box = soup.select('div.C1 div.box')
  for i in xrange(len(h1)): put_item(h1[i], box[i])

  h1 = soup.select('div.C2 h1 a')
  box = soup.select('div.C2 div.box')
  for i in xrange(len(h1)): put_item(h1[i], box[i])
    
  output.write(footer)

  return output.getvalue()