# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/
from bs4 import BeautifulSoup
from bs4.element import Tag
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from pregon.xutils import *

def get_xml(args):

  output = StringIO.StringIO()
  output.write(header)

  link = "http://www.pregon.com.ar/"
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)

  today_date = get_today_date(soup)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def get_main():
    title = get_one(soup, "div.destacadasbox100 h1.box100-titulo a")
    if title is None: return None

    desc = get_one(soup, "div.destacadasbox100 p")
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

    lead = get_one(soup, "div.destacadasbox100 h2.box100-antetitulo")
    if lead is not None:
      output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead.text )
    
    output_write( u'<news:subheader type="plain" meta="bajada"><![CDATA[%s]]></news:subheader>' % desc.text )

    img = get_one(soup, "div.destacadasbox100 div.box100-foto img")
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
    output_write( u'<pubDate>%s</pubDate>' % get_date(today_date, spans[0].strong.text) )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )


    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>' )
    
    output_write( u'<news:subheader type="plain" meta="bajada"><![CDATA[%s]]></news:subheader>' % spans[1].text )

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