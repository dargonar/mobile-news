# -*- coding: utf-8 -*-
#http://www.ecosdiariosweb.com.ar/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from urllib import urlencode
from datetime import datetime, timedelta

import re
import StringIO

from ecosdiarios import utils

def get_xml(args):

  output = StringIO.StringIO()
  output.write(utils.header)
  
  soup = BeautifulSoup(utils.read_clean(utils.link))
  today_date = utils.get_today_date(soup)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(art0, art1):

    title    = art0.tr.a.text.strip()
    href     = '%s%s' % (utils.link, art0.tr.a['href'])
    guid     = re.compile('&id=(\d+)').findall(href)[0]
    category = art1.tr.td.span.text.strip()

    img = None
    pes = art1.find_all('p')
    if len(pes) > 1:
      if pes[0].img is not None: img = '%s%s' % (utils.link, pes[0].img['src'])
      bajada = pes[1].text
    else:
      bajada = pes[0].text

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>' )
    output_write( u'<link><![CDATA[%s]]></link>' % href )
    output_write( u'<guid isPermaLink="false">%s</guid>' % guid )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate></pubDate>' )
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


  arts=soup.select('table.blog table.contentpaneopen')
  for i in xrange(len(arts)/2): put_item(arts[2*i], arts[2*i+1])

  output.write(utils.footer)

  return output.getvalue()