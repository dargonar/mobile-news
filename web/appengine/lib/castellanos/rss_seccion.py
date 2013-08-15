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
  
  noticias = []
  section_id = args['host']
  
  output = StringIO.StringIO()
  output.write(get_header())
  
  link = u'http://www.diariocastellanos.net/%s' % section_id
  content = read_clean(link, args.get('inner_url'), use_cache=args.get('use_cache'))
  # logging.error('-----------------------------')
  # logging.error('link:%s'%link)
  # logging.error('-----------------------------')
  # content = urlopen(link).read()
  
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

  def get_text_sin_strong(soap_element):
    if soap_element.strong is not None:
      soap_element.strong.decompose()
    return soap_element.text
    
  def get_main():
    noticia = getOne("#Content .ColumnaAB .Noticia.Principal")
    title = noticia.select("h2 a")[0]
    href = sha1(title['href']).digest().encode('hex')
    if href in noticias:
      return None
    noticias.append(href)
    
    desc = noticia.select("p")[0]
    
    _time = desc.select('strong.Time')
    my_time = _time[0].text if len(_time)>0 else '00:00'
    
    _section = noticia.select("h4 a")
    section = _section[0].text if len(_section)>0 else ''
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    #output_write( u'<description>%s</description>' % get_text_sin_strong(desc) )
    output_write( u'<description><![CDATA[&nbsp;]]></description>')
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    output_write( u'<pubDate>%s</pubDate>' % get_date((my_time), today_date) )
    #output_write( u'<pubDate></pubDate>' )
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % section)

    lead = getOne("#Content .ColumnaA .Noticia.Destacada H4 a")
    if lead is not None:
      output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead.text )
    
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % get_text_sin_strong(desc))

    img = getOne("#Content .ColumnaA .Noticia.Destacada .Foto img")
    if img is not None:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Diario Castellanos</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  def put_item(noticia):
    
    title = noticia.select('h3 a')[0]
    
    href = sha1(title['href']).digest().encode('hex')
    if href in noticias:
      return None
    
    noticias.append(href)
    
    desc = noticia.select("p")[0]
    _time = desc.select('strong')
    my_time = _time[0].text if len(_time)>0 else '00:00'
    
    _section = noticia.select("h4 a")
    section = _section[0].text if len(_section)>0 else '<![CDATA[&nbsp;]]>'
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title.text )
    #output_write( u'<description>%s</description>' % get_text_sin_strong(noticia.p))
    output_write( u'<description><![CDATA[&nbsp;]]></description>')
    output_write( u'<link>%s</link>' % title['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(title['href'])[0] )
    
    output_write( u'<pubDate>%s</pubDate>' % get_date(my_time, today_date))
    output_write( u'<author></author>' )
    output_write( u'<category>%s</category>' % section)

    lead = noticia.select('h4 a')
    output_write( u'<news:lead type="plain" meta="volanta">%s</news:lead>' % lead[0].contents if len(lead)>0 else '')
    
    #output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )
    output_write( u'<news:subheader type="plain" meta="bajada">%s</news:subheader>' % get_text_sin_strong(noticia.p))
    
    img = noticia.select('.Foto img')
    if img is not None and len(img)>0:
      output_write( u'<media:thumbnail url="%s"></media:thumbnail>' % img[0]['src'] )
      output_write( u'<media:text type="plain"></media:text>' )
      output_write( u'<media:credit role="publishing company">Castellanos</media:credit>' )

    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')
  
  def put_link_item(noticia):
    
    href = sha1(noticia['href']).digest().encode('hex')
    if href in noticias:
      return None
    noticias.append(href)
    
    _time = noticia.select('strong')
    time = _time[0].text if len(_time)>0 else '00:00'
    
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % get_text_sin_strong(noticia) )
    output_write( u'<description>%s</description>' % u'') #cgi.escape(noticia.p) )
    output_write( u'<link>%s</link>' % noticia['href'] )
    output_write( u'<guid isPermaLink="false">%s</guid>' % re.compile('\d+').findall(noticia['href'])[0] )
    
    #No tiene fecha la destacada
    output_write( u'<pubDate>%s</pubDate>' % get_date((time), today_date) )
    output_write( u'<author></author>' )
    output_write( u'<category></category>' )

    output_write( u'<news:lead type="plain" meta="volanta"></news:lead>')
    output_write( u'<news:subheader type="plain" meta="bajada"></news:subheader>' )
    output_write( u'<news:meta has_gallery="false" has_video="false" has_audio="false" />' )

    output_write( u'</item>')

  get_main()
  
  selectors = [ u'#Content .ColumnaAB .Noticia'
                # , u'#Content .ColumnaB .Noticia'
                # , u'#Content .ColumnaAB .NoticiasAB .Noticia'
                ]
                
  for selector in selectors:
    items = soup.select(selector)
    for i in xrange(len(items)): 
      if u'Principal' not in items[i]['class']:
        put_item(items[i])
  
  # selectors = [ u'#Content .SideBar .UltimoMomento ul li a'
                # ,u'#Content .ColumnaAB .NoticiasAB.Deportes ul li a'
                # ,u'#Content .ColumnaAB .NoticiasAB.Actualidad ul li a'
                # ]
  
  # for selector in selectors:
    # items = soup.select(selector)
    # for i in xrange(len(items)): 
      # put_link_item(items[i])
      
  # items = soup.select(u'#Content .SideBar .Ranking ul li')
  # for i in xrange(len(items)): 
    # a_tag = items[i].a
    # items[i].a.strong.decompose()
    # put_link_item(a_tag)
  
  # uls = soup.select(u'#Content .NoticiasFoot ul')
  # for ul in uls:
    # items = ul.select(u'li a')
    # for i in xrange(len(items)): 
      # if i > 0: 
        # put_link_item(items[i])

  output.write(get_footer())

  return output.getvalue()