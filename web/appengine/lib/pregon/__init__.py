# -*- coding: utf-8 -*-

import logging
import re

from bs4 import BeautifulSoup
from collections import OrderedDict
from datetime import datetime
from utils import months, date_add_str, read_clean, clean_content, multi_fetch, date2iso
from xmlbuild import XMLBuild

conf = {  'title'       : u'PREGON',
          'url'         : u'http://www.pregon.com.ar/',
          'description' : u'El diario de Jujuy',
          'copyright'   : u'Todos los Derechos Registrados - Pregon Jujuy- San Salvador de Jujuy - Argentina Año 2001',
          'logo'        : u'http://www.pregon.com.ar/img/LOGOPREGON.png' }

main_url = 'http://www.pregon.com.ar/'

# Viernes 16 de Agosto de 2013
def get_header_date(strdate):
  parts = filter(lambda a: a!='de',strdate.split()[1:])
  inx = months.index(parts[1].lower())
  return datetime(int(parts[2]), inx+1, int(parts[0]))

# 15 de Agosto de 2013 | 22:35 hs.
def get_noticia_date(strdate):
  hh, mm = strdate.split('|')[1].strip().split()[0].split(':')
  parts = strdate.split()
  parts = parts[0:parts.index('|')]
  parts = filter(lambda a: a!='de',parts)
  inx = months.index(parts[1].lower())
  return datetime(int(parts[2]), inx+1, int(parts[0]), int(hh), int(mm))

def rss_index(args):
  soup = BeautifulSoup(read_clean('http://www.pregon.com.ar/'))
  today_date = get_header_date(soup.select('div.clima div')[-1].text)

  builder = XMLBuild(conf, today_date)

  main = soup.select('div.destacadasbox100')[0]

  item = {}
  item['title']     = main.h1.text
  item['link']      = main.a['href']
  item['guid']      = re.compile('\d+').findall(item['link'])[0]
  item['thumbnail'] = main.img['src'] if main.img else None
  item['subheader'] = main.p.text
  builder.add_item(item)

  headers = soup.select('div.C1 h1 a') + soup.select('div.C2 h1 a')
  bodies  = soup.select('div.C1 div.box') + soup.select('div.C2 div.box')
  
  for i in xrange(len(headers)):
    head, body = headers[i], bodies[i]

    spans = body.p.find_all('span')

    item = {}
    item['title']     = head.text
    item['link']      = head['href']
    item['guid']      = re.compile('\d+').findall(item['link'])[0]
    item['pubDate']   = date_add_str(today_date, spans[0].strong.text)
    item['thumbnail'] = body.div.img['src'] if body.div.img else None
    item['subheader'] = spans[1].text
    builder.add_item(item)    
    
  return builder.get_value()

def rss_menu(args):
  
  soup = BeautifulSoup(read_clean('http://www.pregon.com.ar/'))
  today_date = get_header_date(soup.select('div.clima div')[-1].text)

  builder = XMLBuild(conf, today_date)

  for n in soup.select('ul#menudesplegable li ul li a'):
    
    guid, _ = re.compile('\d+').findall(n['href'])
    if int(guid) != 4: 
      continue

    item = {}
    item['title']     = n.text
    item['link']      = n['href']
    item['guid']      = guid
    item['pubDate']   = date_add_str(today_date, '00:00')
    builder.add_section(item)

  return builder.get_value()

def rss_section(args):

  soup = BeautifulSoup(read_clean('http://www.pregon.com.ar/subseccion/4/%s/dummy.html' % args['host']))
  today_date = get_header_date(soup.select('div.clima div')[-1].text)
  
  builder = XMLBuild(conf, today_date)
  category = soup.select('h1.antetituloNormal')[0].text.split()[-1]

  for n in soup.select('div.contLineaTitulo'):
    
    item = {}
    item['title']     = n.h1.text
    item['link']      = n.a['href']
    item['guid']      = re.compile('\d+').findall(item['link'])[0]
    item['category']  = category
    item['thumbnail'] = n.img['src'] if n.img else None
    item['subheader'] = n.p.text
    builder.add_item(item)

  return builder.get_value()

def rss_noticia(args):

  full_url = 'http://www.pregon.com.ar/nota/%s/dummy.html' % args['host']

  soup = BeautifulSoup(read_clean(full_url))
  today_date = get_header_date(soup.select('div.clima div')[-1].text)

  builder = XMLBuild(conf, today_date)

  body = soup.select('div.main div.col1')[0]
 
  divimg = body.find_all('div',{'class':'fotonota'})

  item = {}
  item['title']     = body.h1.text
  item['category']  = body.h2.text
  item['link']      = full_url
  item['guid']      = args['host']
  item['thumbnail'] = divimg[0].img['src'] if len(divimg) else None
  item['pubDate']   = date2iso(get_noticia_date(body.strong.text))
  item['content']   = body.find_all('div',{'class':'cc2'})[0].p.__repr__().decode('utf-8')
  
  builder.add_item(item)
  return builder.get_value()

def rss_funebres(args):

  soup = BeautifulSoup(read_clean('http://www.pregon.com.ar/subseccion/2/1/funebres.html'))
  today_date = get_header_date(soup.select('div.clima div')[-1].text)

  # Obtenemos las url funebres
  urls = {}
  for n in soup.select('div.contLineaTitulo h1 a'):
    urls[n['href']] = None

  builder = XMLBuild(conf, today_date)

  def handle_result(rpc, url):
    result = rpc.get_result()
    if result.status_code == 200: 
      soup = BeautifulSoup(clean_content(result.content))
      content = soup.select('div.main div.col1 div.cc2')[0].__repr__().decode('utf-8')
      #content = re.compile(r'<br.*?/>').sub('', content)
      #content = re.sub(r'<([a-z][a-z0-9]*)([^>])*?(/?)>', r'<\1>', content)

      tmp = get_noticia_date(soup.select('div.main div.col1 strong')[0].text)

      item = {}
      item['title']       = 'Sepelios %s' % tmp.strftime('%d/%m')
      item['description'] = content
      item['link']        = url
      item['guid']        = re.compile('\d+').findall(item['link'])[0]
      item['pubDate']     = tmp.strftime("%a, %d %b %Y %H:%M:%S")
      item['category']    = 'Sepelios %s' % tmp.strftime('%d/%m')

      builder.add_funebre(item)

  # Traemos en paralelo (primeras 4)
  multi_fetch(urls.keys()[:4], handle_result)

  # HACK POR EL DIA (no se muestra nunca el LAST FUNEBRE)
  builder.add_funebre({})
  
  return builder.get_value()


def get_mapping():
  return {
    'httpurl' : OrderedDict([
      ('section://main' , 'X: rss_index') ,
      ('noticia://'     , 'X: rss_noticia') ,
      ('section://'     , 'X: rss_section') ,
      ('menu://'        , 'X: rss_menu') ,
      ('funebres://'    , 'X: rss_funebres') ,
    ]), 
    'templates-small': OrderedDict([
      ('section://main' , {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'}),
      ('noticia://'     , {'pt': '3_new.xsl',          'ls': '3_new.xsl'}),
      ('section://'     , {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'}),
      ('menu://'        , {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'}),
      ('funebres://'    , {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'}),
    ]),
    'templates-big': OrderedDict([
      ('section://main'          , {'pt': '1_tablet_main_list.xsl',                  'ls': '1_tablet_main_list.xsl'}),
      
      ('menu_section://main'     , {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_portrait.xsl'}),
      ('menu://'                 , {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'}),
      ('section://'              , {'pt': '1_tablet_section_list.xsl',               'ls': '1_tablet_section_list.xsl'}),
      ('noticia://'              , {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'}),
      
      ('ls_menu_section://main'  , {'pt': '2_tablet_noticias_index_landscape.xsl',   'ls': '2_tablet_noticias_index_landscape.xsl'}),
      ('ls_menu_section://'      , {'pt': '2_tablet_noticias_seccion_landscape.xsl', 'ls': '2_tablet_noticias_seccion_landscape.xsl'}),
      ('ls_section://'           , {'pt': '2_section_list.xsl',                      'ls': '2_section_list.xsl'}),
      ('ls_noticia://'           , {'pt': '3_tablet_new_landscape.xsl',              'ls': '3_tablet_new_landscape.xsl'}),

      ('funebres://'             , {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'}),
    ]),
    'extras': {
      'has_clasificados' : False,
      'has_funebres'     : True,
      'has_farmacia'     : False,
      'has_cartelera'    : False,
    }, 
  }