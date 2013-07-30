# -*- coding: utf-8 -*-
import logging
import StringIO
import urllib2
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
  'com.diventi.eldia'     : 'eldia',
  'com.diventi.mobipaper' : 'eldia' 
}

mapping = { 
  'eldia' : {
    'httpurl' : {
      'section://main'  : 'http://www.eldia.com.ar/rss/index.aspx' ,
      'noticia://'      : 'http://www.eldia.com.ar/rss/noticia.aspx?id=%s',
      'section://'      : 'http://www.eldia.com.ar/rss/index.aspx?seccion=%s',
      'clasificados://' : 'http://www.eldia.com.ar/mc/clasi_rss_utf8.aspx?idr=%s&app=1',
      'menu://'         : 'http://www.eldia.com.ar/rss/secciones.aspx',
      'funebres://'     : 'http://www.eldia.com.ar/mc/fune_rss_utf8.aspx',
      'farmacia://'     : 'http://www.eldia.com.ar/extras/farmacias_txt.aspx',
      'cartelera://'    : 'http://www.eldia.com.ar/extras/carteleradecine_txt.aspx',
    }, 
    'templates-small': {
      'section://main'  : {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'},
      'noticia://'      : {'pt': '3_new.xsl',          'ls': '3_new.xsl'},
      'section://'      : {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'},
      'clasificados://' : {'pt': '5_clasificados.xsl', 'ls': '5_clasificados.xsl'},
      'menu://'         : {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'},
      'funebres://'     : {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'},
      'farmacia://'     : {'pt': '7_farmacias.xsl',    'ls': '7_farmacias.xsl'},
      'cartelera://'    : {'pt': '8_cartelera.xsl',    'ls': '8_cartelera.xsl'},
    },
    'templates-big': {
      'section://main'  : {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_landscape.xsl'},
      'noticia://'      : {'pt': '3_new.xsl',                               'ls': '3_new.xsl'},
      'section://'      : {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_seccion_landscape.xsl'},
      'clasificados://' : {'pt': '5_clasificados.xsl',                      'ls': '5_clasificados.xsl'},
      'menu://'         : {'pt': '4_menu.xsl',                              'ls': '4_menu.xsl'},
      'funebres://'     : {'pt': '6_funebres.xsl',                          'ls': '6_funebres.xsl'},
      'farmacia://'     : {'pt': '7_farmacias.xsl',                         'ls': '7_farmacias.xsl'},
      'cartelera://'    : {'pt': '8_cartelera.xsl',                         'ls': '8_cartelera.xsl'},
    },
  }
}

class ScreenController(FrontendHandler):
  
  def get_screen(self, **kwargs):
    
    # Parametros del request
    appid = self.request.POST['appid'] # nombre de la app
    url   = self.request.POST['url']   # url interna
    size  = self.request.POST['size']  # small, big
    ptls  = self.request.POST['ptls']  # pt, ls

    url_map = mapping[ apps_id[appid] ]['httpurl']
    template_map = mapping[ apps_id[appid] ]['templates-%s' % size]

    # Armamos la direccion del xml
    logging.error('url_map %s' % url_map)
    logging.error('url %s' % url)
    httpurl = ''
    for k in url_map:
      if url.startswith(k):
        httpurl = url_map[k]
        if '%s' in httpurl:
          httpurl = httpurl % url[url.index('//')+2:]
        break

    # Obtenemos el template
    template = ''
    for k in template_map:
      if url.startswith(k):
        template = template_map[k][ptls]
        break

    # Traemos el xml y lo transformamos en un dict
    xml = XML2Dict()
    logging.error('httpurl %s' % httpurl)
    result = urllib2.urlopen(httpurl).read()
    r = xml.fromstring(result)

    # Reemplazamos las imagens por el sha1 de la url
    imgs = []
    for i in r.rss.channel.item:
      if hasattr(i, 'thumbnail'):
        img = i.thumbnail.value.attrs.url
        i.thumbnail.value.attrs.url = sha1(img).digest().encode('hex')
        imgs.append(img)

    rv = self.render_template('ws/%s' % template, **{'data': r.rss.channel} )
    
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