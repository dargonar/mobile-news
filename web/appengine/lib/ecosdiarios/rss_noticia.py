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
from ecosdiarios import xutils

def get_xml(args):

  output = StringIO.StringIO()
  output.write(xutils.header)

  full_url = u'http://www.ecosdiariosweb.com.ar/index.php?option=com_content&view=article&id=%s' % args.get('host')

  content = read_clean(full_url, args.get('inner_url'),use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item():
    
    arts=soup.select('table#majtable table.contentpaneopen')
    
    title    = arts[0].tr.td.text
    rawdate  = arts[1].tr.td.text
    category = ''

    img = None
    pe = arts[1].find_all('tr')[1].td.p
    if pe is not None and pe.img is not None: 
      img = '%s%s' % (xutils.link, pe.img['src'])

    content = ''
    for p in arts[1].find_all('tr')[1].td.find_all('p'): 
      content = content + p.__repr__()

    content = xutils.remove_img_tags(unicode(content.decode('utf-8')))

    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description></description>' )
    output_write( u'<link><![CDATA[%s]]></link>' % full_url )
    output_write( u'<guid isPermaLink="false">%s</guid>' % args.get('host') )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % xutils.get_date_from_string(rawdate) )
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % category )


    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>' )
    
    #output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>')

    output_write( u'<news:content type="html" meta="contenido"><![CDATA[%s]]></news:content>' % content)

    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img )
    
    output_write( u'<media:text type="plain"></media:text>' )
    output_write( u'<media:credit role="publishing company">EcosDiarios</media:credit>' )

    output_write( u'<media:text type="plain"></media:text>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  put_item()
    
  output.write(xutils.footer)

  return output.getvalue()