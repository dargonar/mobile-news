# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/
import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from pregon.xutils import *

def get_xml(args):

  output = StringIO.StringIO()
  output.write(header)

  link = 'http://www.pregon.com.ar/vernoticia.asp?id=%s' % args.get('host')
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)

  today_date = get_today_date(soup)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(realurl):
    
    category = get_one(soup, 'h2.antetituloNormal')
    if category is None: 
      category = ''
    else:
      category = category.text

    hhmm = get_one(soup, 'div.col1 strong')
    if hhmm is None: 
      hhmm = '00:00'
    else:
      hhmm = hhmm.text.split('|')[1].strip().split()[0]

    title = get_one(soup, 'div.col1 h1.tituloAzulNota').text
    descr = get_one(soup, 'div.col1 h3.bajada').text

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>' )
    output_write( u'<link>%s</link>' % realurl )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(realurl)[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % get_date(today_date, hhmm) )
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % category )


    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>' )
    
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % descr)

    content = get_one(soup, 'div.col1 div.cc2 p')
    if content is not None: 
      content = content.text
    else:
      content = ''

    output_write( u'<news:content type="html" meta="contenido"><![CDATA[%s]]></news:content>' % content)

    img = get_one(soup, 'div.contfotonota img')
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