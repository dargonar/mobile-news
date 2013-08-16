# -*- coding: utf-8 -*-
import logging
import StringIO
import urllib2
import re
import importlib

from datetime import datetime, timedelta
from HTMLParser import HTMLParser

from hashlib import sha1

from contextlib import closing
from zipfile import ZipFile, ZIP_DEFLATED

from google.appengine.ext import db
from google.appengine.api import mail
from google.appengine.api import taskqueue
from google.appengine.api import memcache

from webapp2 import cached_property
from utils import FrontendHandler, get_or_404, read_clean
from lhammer.xml2dict import XML2Dict

from utils import apps_id, build_inner_url

def my_read_url(url):
  logging.info('Not in cache .. reading (%s)' % url)
  return urllib2.urlopen(url, timeout=15).read()

def get_mapping(appid):
  i = importlib.import_module(apps_id[appid]+u'.mapping')
  return i.get_mapping()

def get_httpurl(appid, url, mapping=None):  
  if mapping is None:
    mapping = get_mapping(appid)
  # Armamos la direccion del xml
  url_map = mapping[ apps_id[appid] ]['httpurl']
  
  httpurl = ''
  args = {}
  for k in url_map:
    if url.startswith(k):
      httpurl = url_map[k]
      #HARKU
      args['host'] = url[url.index('//')+2: (url.index('?') if '?' in url else None) ]
      
      if '?' in url:
        for i in url[url.index('?')+1:].split('&'):
          tmp = i.split('=')
          args[tmp[0]]=tmp[1]

      break
  return httpurl, args

def build_xml_string(url, httpurl, kwargs, appid, clear_namespaces=False, use_cache=True):
  if httpurl.startswith('X:'):
    i = importlib.import_module(httpurl.split()[1])
    #logging.error('--modulo : %s'%httpurl.split()[1])
    kwargs['inner_url'] = build_inner_url(appid,url)
    kwargs['use_cache'] = use_cache
    result = i.get_xml(kwargs).encode('utf-8')
  else:
    if '%s' in httpurl:
      httpurl = httpurl % kwargs['host']
    
    result = read_clean(httpurl, build_inner_url(appid,url), fnc=my_read_url, use_cache=use_cache)

    # HACKO el DIA:
    if url.startswith('farmacia://') or url.startswith('cartelera://') and apps_id[appid] == 'eldia':
      now = datetime.now()+timedelta(hours=-3)
      result = re.sub(r'\r?\n', '</br>', result)
      result = """<rss xmlns:atom="http://www.w3.org/2005/Atom" 
                    xmlns:media="http://search.yahoo.com/mrss/" 
                    xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" 
                    version="2.0" encoding="UTF-8"><channel>
                    <pubDate>%s</pubDate><item><![CDATA[%s]]></item></channel></rss>""" % (now.strftime("%a, %d %b %Y %H:%M:%S"), result)

  if clear_namespaces:
    result=re.sub(r'<(/?)\w+:(\w+/?)', r'<\1\2', result)
  return result

 
def get_xml(appid, url, use_cache=True):
  httpurl, args = get_httpurl(appid, url, mapping=None)
  r = build_xml_string(url, httpurl, args, appid, clear_namespaces=False, use_cache=use_cache)
  return r

class ScreenController(FrontendHandler):
  
  def get_xml(self, **kwargs):  
    
    appid = self.request.params['appid'] # nombre de la app
    url   = self.request.params['url']   # url interna

    r = get_xml(appid, url)    
    
    self.response.headers['Content-Type'] ='text/xml'
    
    return self.response.write(r) # .encode('utf-8')
    
  def build_html_and_images(self, appid, url, mapping, template_map, extras_map, ptls):
    
    # Armamos la direccion del xml    
    httpurl, args = get_httpurl(appid, url, mapping)
    
    # 
    page_name = ''
    # Obtenemos el template
    template = ''
    for k in template_map:
      if url.startswith(k):
        page_name = k
        template = template_map[k][ptls]
        break

    if httpurl == '' or template == '':
      logging.error('Something is wrong => [%s]' % (url))
      raise('8-(')

    # Traemos el xml y lo transformamos en un dict
    xml = XML2Dict()
    r = xml.fromstring(build_xml_string(url, httpurl, args, appid, clear_namespaces=True ))

    # Reemplazamos las imagens por el sha1 de la url
    imgs = []

    if type(r.rss.channel.item) == type([]):
      items = r.rss.channel.item
    else:
      items = [r.rss.channel.item]

    for i in items:
      if hasattr(i, 'thumbnail'):
        img = i.thumbnail.attrs.url
        i.thumbnail.attrs.url = sha1(img).digest().encode('hex')
        imgs.append(img)

    if extras_map['has_clasificados'] == True:
      i = importlib.import_module(apps_id[appid]+'.rss_clasificados')
      extras_map['clasificados'] = i.get_classifieds()

    #return self.render_response('ws/%s' % template, **{'data': r.rss.channel, 'cfg': extras_map } )
    rv = self.render_template('ws/%s' % template, **{'data': r.rss.channel, 'cfg': extras_map, 'page_name': page_name } )
    
    return imgs, rv
  
  def get_html(self, **kwargs):  
    # Parametros del request
    appid = self.request.params['appid'] # nombre de la app
    url   = self.request.params['url']   # url interna
    size  = self.request.params['size']  # small, big
    ptls  = self.request.params['ptls']  # pt, ls
    
    mapping = self.get_mapping(appid)
    
    template_map = mapping[ apps_id[appid] ]['templates-%s' % size]
    extras_map = mapping[ apps_id[appid] ]['extras']
    
    imgs, rv = self.build_html_and_images(appid, url, mapping, template_map, extras_map, ptls)
    
    # Set up headers for browser to correctly recognize ZIP file
    self.response.headers['Content-Type'] ='text/html'
    self.response.write(rv)
    return
    
  def get_screen(self, **kwargs):  
    # Parametros del request
    appid = self.request.params['appid'] # nombre de la app
    url   = self.request.params['url']   # url interna
    size  = self.request.params['size']  # small, big
    ptls  = self.request.params['ptls']  # pt, ls
    
    mapping = get_mapping(appid)
    
    template_map = mapping[ apps_id[appid] ]['templates-%s' % size]
    extras_map = mapping[ apps_id[appid] ]['extras']
    
    imgs, rv = self.build_html_and_images(appid, url, mapping, template_map, extras_map, ptls)
    
    # Set up headers for browser to correctly recognize ZIP file
    self.response.headers['Content-Type'] ='application/zip'
    self.response.headers['Content-Disposition'] = 'attachment; filename="screen.zip"'

    # compress files and emit them directly to HTTP response stream
    output = StringIO.StringIO()
    outfile = ZipFile(output, "w", ZIP_DEFLATED)
    
    # repeat this for every URL that should be added to the zipfile
    if len(imgs):
      outfile.writestr('images.txt', ','.join(imgs))
    
    outfile.writestr('content.html', rv.encode('utf-8'))

    #Incluimos menu si es section://main
    if url == 'section://main':
      xx , menu = self.build_html_and_images(appid, 'menu://', mapping, template_map, extras_map, ptls)
      outfile.writestr('menu://.m', menu.encode('utf-8'))
    
    #Incluimos menu si es section://main
    if url.startswith('noticia://') and size=='big':
      logging.error('------------------------')
      logging.error('------------------------ %s' % url)
      # xx , menu = self.build_html_and_images(appid, 'menu://', mapping, template_map, extras_map, ptls)
      # outfile.writestr('menu.html', menu.encode('utf-8'))

      
    outfile.close()
    
    self.response.out.write(output.getvalue())
