# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

from hashlib import sha1

import cgi
import re
import StringIO

def get_xml():
  
  noticias = []
  

  today_date = ""

  header = u"""<?xml version="1.0" encoding="UTF-8" ?>
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

  footer = u"""
   </channel>
  </rss>
  """

  output = StringIO.StringIO()
  output.write(header)

  link = u'http://www.diariocastellanos.net/Default.aspx'
  content = urlopen(link).read()
  
  soup = BeautifulSoup(content)
  
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.clima div')

  # 31 de Julio de 2013
  # parts = tmp[len(tmp)-1].text.split()
  # inx = months.index(parts[3].lower())
  today_date = datetime.now() #datetime(int(parts[5]), inx+1, int(parts[1]) )

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
    title = getOne("#Content .ColumnaA .Noticia.Destacada h3 a")
    if title is None: 
      output_write( u'<!-- NO TITLE -->')
      return None

    desc = getOne("#Content .ColumnaA .Noticia.Destacada p")
    if desc is None: 
      output_write( u'<!-- NO DESC -->')
      return None
    
    href = sha1(title['href']).digest().encode('hex')
    if href in noticias:
      return None
    noticias.append(href)
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    output_write( u'<description>%s</description>' % desc.text )
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate></pubDate>' )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )

    lead = getOne("#Content .ColumnaA .Noticia.Destacada H4 a")
    if lead is not None:
      output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead.text )
    
    output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )

    img = getOne("#Content .ColumnaA .Noticia.Destacada .Foto img")
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Diario Castellanos</media:credit>' )

    output_write( u'<news:meta has_gallery="true" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  def put_item(noticia):
    
    title = noticia.select('h3 a')[0]
    
    href = sha1(title['href']).digest().encode('hex')
    if href in noticias:
      return None
    noticias.append(href)
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    output_write( u'<description>%s</description>' % noticia.p.text) #cgi.escape(noticia.p) )
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % datetime.now())#getDate(spans[0].strong.text) )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )

    lead = noticia.select('h4 a')
    output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead[0].contents if len(lead)>0 else '')
    
    output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )

    img = noticia.select('.Foto img')
    if img is not None and len(img)>0:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img[0]['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Castellanos</media:credit>' )

    output_write( u'<news:meta has_gallery="true" has_video="false" has_audio="false" />' )

    output_write( u'</item>')
  
  def put_link_item(noticia):
    
    href = sha1(noticia['href']).digest().encode('hex')
    if href in noticias:
      return None
    noticias.append(href)
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % noticia.text )
    output_write( u'<description>%s</description>' % u'') #cgi.escape(noticia.p) )
    output_write( u'<link>%s</link>' % noticia['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(noticia['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % datetime.now())#getDate(spans[0].strong.text) )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )

    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>')
    output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )
    output_write( u'<news:meta has_gallery="true" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  get_main()
  
  selectors = [ u'#Content .ColumnaA .Noticia'
                , u'#Content .ColumnaB .Noticia'
                , u'#Content .ColumnaAB .NoticiasAB .Noticia']
                
  for selector in selectors:
    items = soup.select(selector)
    for i in xrange(len(items)): 
      if u'Destacada' not in items[i]['class']:
        put_item(items[i])
  
  selectors = [ u'#Content .ColumnaAB .NoticiasAB.<Deportes|Actualidad> ul li a'
                , u'#Content .SideBar .UltimoMomento ul li a'
                #, u'#Content .SideBar .Ranking ul li a'
                ]
  
  for selector in selectors:
    items = soup.select(selector)
    for i in xrange(len(items)): 
      put_link_item(items[i])
      
  items = soup.select(u'#Content .SideBar .Ranking ul li')
  for i in xrange(len(items)): 
    a_tag = items[i].a
    items[i].a.strong.decompose()
    put_link_item(a_tag)
  
  
  uls = soup.select(u'#Content .NoticiasFoot ul')
  for ul in uls:
    items = ul.select(u'li a')
    for i in xrange(len(items)): 
      if i > 0: 
        put_link_item(items[i])

  output.write(footer)

  return output.getvalue()