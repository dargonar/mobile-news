# -*- coding: utf-8 -*-
#http://www.pregon.com.ar/
import logging
from bs4 import BeautifulSoup
from bs4.element import Tag
from datetime import datetime, timedelta

import re
import StringIO

from utils import read_clean
from pregon.xutils import *

from google.appengine.api import urlfetch

def get_xml(args):

  output = StringIO.StringIO()
  output.write(header)

  link = "http://www.pregon.com.ar/subseccion/2/1/funebres.html"
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  soup = BeautifulSoup(content)

  today_date = get_today_date(soup)

  urls = {}
  titles = {}

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def put_item(title, description, link):
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description><![CDATA[%s]]></description>' % description if description is not None and len(description)>0 else '<![CDATA[&nbsp;]]>')
    output_write( u'<link>%s</link>' % link )
    output_write( u'<guid isPermaLink="false">%s</guid>' % link )
    output_write( u'<pubDate>%s</pubDate>' % get_date(today_date, '00:00'))
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