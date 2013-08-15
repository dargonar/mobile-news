# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

from hashlib import sha1

import logging
import cgi
import re
import StringIO

from utils import read_clean
from xutils import get_datetime, get_date, get_header, get_footer

def get_xml(args):
  
  noticia_id = args['host']
  today_date = ""

  output = StringIO.StringIO()
  output.write(get_header())

  link = u'http://www.diariocastellanos.net/%s-dummy.note.aspx' % noticia_id
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  
  soup = BeautifulSoup(content)
  
  date        = soup.select('#TopHeader #Fecha')
  today_date  = get_datetime(date)  

  def getOne(path):
    s = soup.select(path)
    if len(s):
      return s[0]
    return None

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def get_noticia():
    
    art_time    = getOne("#Content .ColumnaAB .NotaHead .Time")
    seccion     = getOne("#Content .ColumnaAB .NotaHead h4")
    title       = getOne("#Content .ColumnaAB .NotaHead h2")
    bajada      = getOne("#Content .ColumnaAB .NotaHead p")
    contenido   = getOne("#Content .ColumnaAB .Nota .NotaData")
    hour        = None
    
    if title is None: 
      output_write( u'<!-- NO TITLE -->')
      return None

    href = link
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    if bajada is not None:
      hour = bajada.strong.text
      bajada.strong.decompose()
      output_write( u'<description>%s</description>' % bajada.text )
    else:
      output_write( u'<description><![CDATA[&nbsp;]]></description>')
    
    output_write( u'<link>%s</link>' % link )
    output_write( u'<guid isPermaLink="false">%s</guid>' % noticia_id )
    
    if hour is not None:
      output_write( u'<pubDate>%s</pubDate>' % get_date(hour, today_date))
    else:
      output_write( u'<pubDate></pubDate>')
    
    output_write( u'<author></author>' )
    if seccion is not None:
      output_write( u'<category>%s</category>' % seccion.text)
      output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % seccion.text )
    else:
      output_write( u'<category></category>')
    
    if bajada is not None:    
      output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % bajada.text )
    else:
      output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )
    
    if contenido is not None:    
      output_write( u'<news:content type="html" meta="contenido">%s</news:content>' % contenido.text )
    else:
      output_write( u'<news:content type="html" meta="contenido"></news:content>')
    
    img = getOne("#Content .ColumnaAB .NotaFotos .Foto img")
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Diario Castellanos</media:credit>' )
    
    imgs = soup.select(u'#Content .ColumnaAB .NotaFotos #gallery ul.ad-thumb-list li a img')
    if imgs is not None and len(imgs)>0:
      output_write( u'<media:group>')
      for i in xrange(len(imgs)): 
        output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % imgs[i]['src'] )
        output_write( u'<media:text type="plain"></media:text>' )
        output_write( u'<media:credit role="publishing company">Diario Castellanos</media:credit>' )
      output_write( u'</media:group>')
      output_write( u'<news:meta has_gallery="true" has_video="false" has_audio="false" />' )
    else:
      output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )
    
    output_write( u'</item>')
  
  get_noticia()
  output.write(get_footer())

  return output.getvalue()