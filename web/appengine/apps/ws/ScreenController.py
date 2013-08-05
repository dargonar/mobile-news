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

from webapp2 import cached_property
from utils import FrontendHandler, get_or_404
from lhammer.xml2dict import XML2Dict

apps_id = { 
  'com.diventi.eldia'       : 'eldia',
  'com.diventi.mobipaper'   : 'eldia',
  'com.diventi.pregon'      : 'pregon',
  'com.diventi.castellanos' : 'castellanos',
}

class ScreenController(FrontendHandler):
  
  def build_xml_string(self, url, httpurl, kwargs):
    if httpurl.startswith('X:'):
      i = importlib.import_module(httpurl.split()[1])
      logging.error('--modulo:%s'%httpurl.split()[1])
      result = i.get_xml(kwargs).encode('utf-8')
    else:
      if '%s' in httpurl:
        httpurl = httpurl % kwargs['host']
      result = urllib2.urlopen(httpurl).read()

      # HACKO el DIA:
      if url.startswith('farmacia://') or url.startswith('cartelera://') and apps_id[appid] == 'eldia':
        now = datetime.now()+timedelta(hours=-3)
        result = re.sub(r'\r?\n', '</br>', result)
        result = """<rss xmlns:atom="http://www.w3.org/2005/Atom" 
                      xmlns:media="http://search.yahoo.com/mrss/" 
                      xmlns:news="http://www.diariosmoviles.com.ar/news-rss/" 
                      version="2.0" encoding="UTF-8"><channel>
                      <pubDate>%s</pubDate><item><![CDATA[%s]]></item></channel></rss>""" % (now.strftime("%a, %d %b %Y %H:%M:%S"), result)

    result=re.sub(r'<(/?)\w+:(\w+/?)', r'<\1\2', result)
    return result
  
  def get_httpurl(self, appid, url, mapping=None):  
    if mapping is None:
      mapping = self.get_mapping(appid)
    # Armamos la direccion del xml
    url_map = mapping[ apps_id[appid] ]['httpurl']
    httpurl = ''
    args = {}
    for k in url_map:
      if url.startswith(k):
        httpurl = url_map[k]
        #HARKU
        args['host'] = url[url.index('//')+2: (url.index('?') if '?' in url else -1) ]
        
        if '?' in url:
          for i in url[url.index('?')+1:].split('&'):
            tmp = i.split('=')
            args[tmp[0]]=tmp[1]

        break
    return httpurl, args

  
  def get_mapping(self, appid):
    i = importlib.import_module(apps_id[appid]+u'.mapping')
    return i.get_mapping() #.encode('utf-8')
    
  def get_xml(self, **kwargs):  
    
    appid = self.request.params['appid'] # nombre de la app
    url   = self.request.params['url']   # url interna
    
    httpurl, args = self.get_httpurl(appid, url, mapping=None)
    
    r = self.build_xml_string(url, httpurl, args)
    
    self.response.headers['Content-Type'] ='text/xml'
    
    return self.response.write(r) # .encode('utf-8')
    
  def get_screen(self, **kwargs):  
    # Parametros del request
    appid = self.request.params['appid'] # nombre de la app
    url   = self.request.params['url']   # url interna
    size  = self.request.params['size']  # small, big
    ptls  = self.request.params['ptls']  # pt, ls
    
    mapping = self.get_mapping(appid)
    
    template_map = mapping[ apps_id[appid] ]['templates-%s' % size]
    extras_map = mapping[ apps_id[appid] ]['extras']
    
    # Armamos la direccion del xml    
    httpurl, args = self.get_httpurl(appid, url, mapping)
    
    # Obtenemos el template
    template = ''
    for k in template_map:
      if url.startswith(k):
        template = template_map[k][ptls]
        break

    if httpurl == '' or template == '':
      logging.error('Something is wrong => [%s]' % (url))
      raise('8-(')

    # Traemos el xml y lo transformamos en un dict
    xml = XML2Dict()
    r = xml.fromstring(self.build_xml_string(url, httpurl, args ))

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
      i = importlib.import_module(apps_id[appid]+'.extras')
      extras_map['clasificados'] = i.get_classifieds()

    rv = self.render_template('ws/%s' % template, **{'data': r.rss.channel, 'cfg': extras_map } )
    
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
    outfile.close()
    
    self.response.out.write(output.getvalue())
