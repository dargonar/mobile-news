# -*- coding: utf-8 -*-

import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from ecosdiarios import xutils

def get_xml(args):

  output = StringIO.StringIO()
  output.write(xutils.header)

  content = read_clean('%s/index.php?option=com_content&view=category&layout=blog&id=%s&Itemid=3' % (xutils.link, args.get('host')), args.get('inner_url'), use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(art0, art1, category):

    title    = art0.tr.a.text.strip()
    href     = '%s%s' % (xutils.link, art0.tr.a['href'])
    guid     = re.compile('&id=(\d+)').findall(href)[0]
    artdate  = xutils.get_date_from_string(art1.tr.td.text)

    img = None
    pes = art1.find_all('p')
    if len(pes) > 1:
      if pes[0].img is not None: img = '%s%s' % (xutils.link, pes[0].img['src'])
      bajada = pes[1].text
    else:
      bajada = pes[0].text

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>' )
    output_write( u'<link><![CDATA[%s]]></link>' % href )
    output_write( u'<guid isPermaLink="false">%s</guid>' % guid )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % artdate)
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % category)

    output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % category )
    output_write( u'<news:subheader type="plain" meta="bajada"><![CDATA[%s]]></news:subheader>' % bajada )

    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img )
    
    output_write( u'<media:text type="plain"></media:text>' )
    output_write( u'<media:credit role="publishing company">EcosDiarios</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  category = soup.select('div.componentheading')[0].text
  arts=soup.select('table.blog table.contentpaneopen')
  for i in xrange(len(arts)/2): 
    put_item(arts[2*i], arts[2*i+1],category)

  output.write(xutils.footer)

  return output.getvalue()