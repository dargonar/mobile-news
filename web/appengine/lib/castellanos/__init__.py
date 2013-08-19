# -*- coding: utf-8 -*-
import logging
import re

from bs4 import BeautifulSoup
from collections import OrderedDict
from datetime import datetime
from utils import months, date_add_str, read_clean, clean_content, multi_fetch
from xmlbuild import XMLBuild

conf = {  'title'       : u'DIARIO CASTELLANOS',
          'url'         : u'http://www.diariocastellanos.net',
          'description' : u'El diario de Rafaela, Argentina - Con la verdad no ofendo ni temo',
          'copyright'   : u'2013, Editora del Centro, Propiedad Intelectual N84.363, todos los derechos reservados',
          'logo'        : u'http://www.diariocastellanos.net/images/header/castellanos.png' }

# Jueves 15 Agosto 2013 X Actualizado 12:40
def get_header_date(strdate):
  parts = strdate.split()[1:]
  inx = months.index(parts[1].lower())
  return datetime(int(parts[2]), inx+1, int(parts[0]))

def rss_index(args):

  soup = BeautifulSoup(read_clean('http://www.diariocastellanos.net/Default.aspx'))
  today_date = get_header_date(soup.select('p#Fecha')[0].text)
  
  builder = XMLBuild(conf, today_date)
  
  for n in soup.select('div.Noticia'):
    item = {}
    item['title']     = n.h3.text
    logging.error(' ************ %s' % n.h3.text)
    item['link']      = n.h3.a['href'] # n.div.a['href']
    item['guid']      = re.compile('\d+').findall(item['link'])[0]
    item['category']  = n.h4.text
    item['thumbnail'] = n.div.img['src'] if n.div else None
    item['pubDate']   = date_add_str(today_date, n.p.strong.text)
    item['subheader'] = n.p.text[6:]
    builder.add_item(item)

  for n in soup.select('div.UltimoMomento li'):
    item = {}
    item['title']     = n.text[6:]
    item['link']      = n.a['href']
    item['guid']      = re.compile('\d+').findall(item['link'])[0]
    item['pubDate']   = date_add_str(today_date, n.strong.text)
    builder.add_item(item)

  return builder.get_value()

def rss_menu(args):
  
  soup = BeautifulSoup(read_clean('http://www.diariocastellanos.net/Default.aspx'))
  today_date = get_header_date(soup.select('p#Fecha')[0].text)
  
  sections = set()

  builder = XMLBuild(conf, today_date)
  for n in soup.select('div#Nav li a'):
    item = {}
    item['title']     = n.text
    item['link']      = n['href']
    item['guid']      = item['link'][item['link'].rfind('/')+1:]
    item['pubDate']   = date_add_str(today_date, '00:00')
    
    if item['guid'] not in sections:
      builder.add_section(item)
      sections.add(item['guid'])

  return builder.get_value()

def rss_seccion(args):
  
  soup = BeautifulSoup(read_clean('http://www.diariocastellanos.net/%s' % args['host']))
  today_date = get_header_date(soup.select('p#Fecha')[0].text)
  
  builder = XMLBuild(conf, today_date)
  items = set()
  
  for n in soup.select('div.Noticia'):    
    divs = n.find_all('div')
    
    item = {}
    item['title']     = n.h3.text if n.h3 else n.h2.text
    item['link']      = divs[-1].a['href'] if len(divs) else n.h3.a['href']
    item['guid']      = re.compile('\d+').findall(item['link'])[0]
    item['category']  = n.h4.text
    item['thumbnail'] = n.div.img['src'] if n.div else None
    item['pubDate']   = date_add_str(today_date, n.p.strong.text)
    item['subheader'] = n.p.text[6:]
    
    if item['guid'] not in items:
      builder.add_item(item)
      items.add(item['guid'])

  return builder.get_value()

def rss_noticia(args):
  
  soup = BeautifulSoup(read_clean('http://www.diariocastellanos.net/%s-dummy.note.aspx' % args['host']))
  today_date = get_header_date(soup.select('p#Fecha')[0].text)

  builder = XMLBuild(conf, today_date)
  
  head = soup.select('div.NotaHead')[0]
  content = soup.select('div.NotaData')[0].__repr__().decode('utf-8')
  content = re.sub(r'<([a-z][a-z0-9]*)([^>])*?(/?)>', r'<\1>', content)
  
  # Sacamos thumbnail
  img   = (soup.select('div.Foto img')[:1] or [None])[0]
  if img: img = img['src']

  # Sacamos galeria / Si hay galeria y no thumnail => la primer foto es el thumb
  group = [tmp['src'] for tmp in soup.select('ul.ad-thumb-list img')]
  if len(group) and img is None: img = group[0]

  item = {}
  item['title']     = head.h2.text
  item['link']      = soup.find_all('meta', {'property':'og:url'})[0].attrs['content']
  item['guid']      = re.compile('\d+').findall(item['link'])[0]
  item['category']  = head.h4.text
  item['thumbnail'] = img
  item['group']     = group
  item['has_gallery'] = 'true' if len(group) > 0 else 'false'
  item['pubDate']   = date_add_str(today_date, head.p.strong.text)
  item['subheader'] = head.p.text[6:]
  item['content']   = content
  
  builder.add_item(item)
  return builder.get_value()


def rss_funebres(args):

  soup = BeautifulSoup(read_clean('http://www.diariocastellanos.net/funebres.aspx'))
  today_date = get_header_date(soup.select('p#Fecha')[0].text)

  # Obtenemos las url funebres
  urls = {}
  for n in soup.select('div.Noticia'):
    divs = n.find_all('div')
    urls[divs[-1].a['href'] if len(divs) else n.h3.a['href']] = None

  builder = XMLBuild(conf, today_date)

  def handle_result(rpc, url):
    result = rpc.get_result()
    if result.status_code == 200: 
      soup = BeautifulSoup(clean_content(result.content))
      content = soup.select('div.NotaData')[0].__repr__().decode('utf-8')
      content = re.sub(r'<([a-z][a-z0-9]*)([^>])*?(/?)>', r'<\1>', content)

      tmp = [int(a) for a in soup.select('strong.Time')[0].text.split('/')+[datetime.now().year]]
      tmp = datetime(tmp[2], tmp[1], tmp[0])

      item = {}
      item['title']       = 'Funebres %s' % tmp.strftime('%d/%m')
      item['description'] = content
      item['link']        = url
      item['guid']        = re.compile('\d+').findall(item['link'])[0]
      item['pubDate']     = tmp.strftime("%a, %d %b %Y %H:%M:%S")
      item['category']    = 'Funebres %s' % tmp.strftime('%d/%m')

      builder.add_funebre(item)

  # Traemos en paralelo (primeras 4)
  multi_fetch(urls.keys()[:4], handle_result)

  # HACK POR EL DIA (no se muestra nunca el LAST FUNEBRE)
  builder.add_funebre({})
  
  return builder.get_value()


#
# TEMPLATES MAPPING
#

def get_mapping():
  return {
    'httpurl' : OrderedDict([
      ('section://main'  , 'X: rss_index'),
      ('noticia://'      , 'X: rss_noticia'),
      ('section://'      , 'X: rss_seccion'),
      ('menu://'         , 'X: rss_menu'),
      ('funebres://'     , 'X: rss_funebres'),
      
      ('menu_section://main'  , 'X: rss_index'),
      ('menu_section://'      , 'X: rss_seccion'),
    ]), 
    'templates-small': OrderedDict([
      ('section://main'  , {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'}),
      ('noticia://'      , {'pt': '3_new.xsl',          'ls': '3_new.xsl'}),
      ('section://'      , {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'}),
      ('menu://'         , {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'}),
      ('funebres://'     , {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'}),
    ]),
    'templates-big': OrderedDict([
      ('section://main'          , {'pt': '1_tablet_main_list.xsl',                  'ls': '1_tablet_main_list.xsl'}),
      
      ('menu://'                 , {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'}),
      ('section://'              , {'pt': '1_tablet_section_list.xsl',               'ls': '1_tablet_section_list.xsl'}),
      ('noticia://'              , {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'}),
      
      ('menu_section://main'     , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',  'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      ('menu_section://'         , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',  'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      # ('menu_section://main'     , {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_portrait.xsl'}),
      # ('menu_section://'         , {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_index_portrait.xsl'}),
      # ('ls_menu_section://main'  , {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_landscape.xsl'}),
      # ('ls_menu_section://'      , {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_seccion_landscape.xsl'}),
      ('ls_section://'           , {'pt': '2_section_list.xsl',                      'ls': '2_section_list.xsl'}),          # q es esto?
      ('ls_noticia://'           , {'pt': '3_tablet_new_landscape.xsl',              'ls': '3_tablet_new_landscape.xsl'}),  # q es esto?

      ('clasificados://'         , {'pt': '5_tablet_clasificados.xsl',               'ls': '5_tablet_clasificados.xsl'}),      
      ('funebres://'             , {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'}),
      ('farmacia://'             , {'pt': '7_tablet_farmacias.xsl',                  'ls': '7_tablet_farmacias.xsl'}),
      ('cartelera://'            , {'pt': '8_tablet_cartelera.xsl',                  'ls': '8_tablet_cartelera.xsl'}),      
    ]),
    'extras': {
      'has_clasificados' : False,
      'has_funebres'     : True,
      'has_farmacia'     : True,
      'has_cartelera'    : True,
    },
  }