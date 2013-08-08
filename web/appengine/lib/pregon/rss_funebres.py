# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/
import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from google.appengine.api import urlfetch

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

  link = "http://www.pregon.com.ar/subseccion/2/1/funebres.html"
  content = urlopen(link).read()
  soup = BeautifulSoup(content)

  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.clima div')

  # # 31 de Julio de 2013
  parts = tmp[len(tmp)-1].text.split()
  inx = months.index(parts[3].lower())
  today_date = datetime(int(parts[5]), inx+1, int(parts[1]) )

  urls = {}
  titles = {}

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

  def put_item(title, description, link):
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description>%s</description>' % description if description is not None and len(description)>0 else '<![CDATA[&nbsp;]]>')
    output_write( u'<link>%s</link>' % link )
    output_write( u'<guid isPermaLink="false">%s</guid>' % link )
    output_write( u'<pubDate>%s</pubDate>' % getDate('00:00'))
    output_write( u'<category>%s</category>' % title)
    output_write( u'</item>')

  def handle_result(rpc, url):
    result = rpc.get_result()
    if result.status_code == 200:
      xs = BeautifulSoup(result.content)
      urls[url] = xs.select('div.cc2 p')[0].text
      titles[url] = xs.select('div.col1 strong')[0].text.split('|')[0].strip()
    else:
      urls[url] = None

  # Use a helper function to define the scope of the callback.
  def create_callback(rpc, url):
    return lambda: handle_result(rpc, url)

  tmp = soup.select('div.contLineaTitulo a')
  for i in xrange(min(len(tmp),3)):
    urls[tmp[i]['href']] = None
    titles[tmp[i]['href']] = None

  rpcs = []
  for url in urls:
    rpc = urlfetch.create_rpc()
    rpc.callback = create_callback(rpc, url)
    urlfetch.make_fetch_call(rpc, url)
    rpcs.append(rpc)

  # Finish all RPCs, and let callbacks process the results.
  for rpc in rpcs:
    rpc.wait()
  
  for url, description in urls.items():
    if description is not None:
      put_item('Sepelios %s' % titles[url], description, url)
  
  output.write(footer)

  return output.getvalue()