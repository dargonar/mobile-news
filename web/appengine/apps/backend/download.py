# -*- coding: utf-8 -*-
import logging
import feedparser
import hashlib

from email.utils import parsedate
from datetime import datetime

from urllib2 import urlopen
from BeautifulSoup import BeautifulSoup

from google.appengine.api import files, taskqueue

from google.appengine.ext import db, blobstore
from google.appengine.api.images import get_serving_url

from webapp2 import RequestHandler
from models  import Category, Article, cats as feeds, DiarioIVC, Kato, ArticlesGallery

from utils import do_slugify
from utils import FrontendHandler, get_or_404
from utils import apps_id, in_cache, build_inner_url

from lhammer.xml2dict import XML2Dict

from apps.ws.ScreenController import get_xml

class DownloadAll(RequestHandler):

  def download_article(self, **kwargs):
    self.request.charset = 'utf-8'
    appid   = self.request.params.get('appid')
    article = self.request.params.get('article')

    # Iteramos todas las noticias de la seccion y las mandamos a bajar
    url = 'noticia://%s' % article
    if not in_cache(build_inner_url(appid,url)):
      #logging.error('---->article not in cache %s => %s ' % (appid, url) )
      get_xml(appid, 'noticia://%s' % article, use_cache=False)
    #else:
    #  logging.error('---->article IS IS CACHE %s => %s ' % (appid, url) )

  def download_section(self, **kwargs):
    self.request.charset = 'utf-8'
    appid   = self.request.params.get('appid')
    section = self.request.params.get('section')

    # Iteramos todas las noticias de la seccion y las mandamos a bajar
    xml = XML2Dict().fromstring(get_xml(appid, 'section://%s' % section, use_cache=False))
    for i in xml.rss.channel.item:
      #logging.error('----> a bajar article ' + i.guid.value)
      taskqueue.add(queue_name='download', url='/download/article', params={'appid': appid, 'article': i.guid.value})
      #break

  def download_newspaper(self, **kwargs):
    
    self.request.charset = 'utf-8'
    appid = self.request.params.get('appid')

    # Iteramos todas las secciones y las mandamos a bajar    
    xml = XML2Dict().fromstring(get_xml(appid, 'menu://', use_cache=False))
    for i in xml.rss.channel.item:
      #logging.error('----> a bajar section ' + i.guid.value)
      taskqueue.add(queue_name='download', url='/download/section', params={'appid': appid, 'section': i.guid.value})
      #break

    # Refrescamos el main
    get_xml(appid, 'section://main', use_cache=False)

  def download_all(self, **kwargs):    
    # Mantenemos una lista de lo que fuimos mandando a bajar
    # por que hay dos appid para ElDia (x ej)
    inverted = dict((v,k) for k,v in apps_id.iteritems())
    for name, appid in inverted.items():
      #if name != 'ecosdiarios': continue
      #logging.error('----> a bajar newspaper ' + appid)
      taskqueue.add(queue_name='download', url='/download/newspaper', params={'appid':appid})
      #break

class ElDia(RequestHandler):
  def download(self, **kwargs):
    for category in feeds:
      if category['type']!='seccion':
        continue
      taskqueue.add(url='/download/feed', params={'feed':category['feed'], 'category':category['key']})

  def download_feed(self, **kwargs):
    self.request.charset = 'utf-8'
    feed = self.request.POST.get('feed')
    category = self.request.POST.get('category')

    d = feedparser.parse(feed)

    for item in d['items']:
      
      if not item.has_key('title'):
        continue

      params = {
        'category'  : category,
        'link'      : item['link'],
        'published' : item['published'],
        'title'     : item['title'],
      }

      taskqueue.add(url='/download/article', params=params)

  def get_link_hash(self, link):
    return hashlib.sha1(link).hexdigest()
    
  def download_article(self, **kwargs):
    self.request.charset = 'utf-8'

    keyname = self.request.POST.get('link')
    
    # Generamos sha1 con la url (unica) y vemos si ya lo teniamos
    link   = self.request.POST.get('link')
    artkey = self.get_link_hash(link)

    art = Article.all(keys_only=True).filter('__key__', db.Key.from_path('Article', artkey)).get()
    if art:
      return

    # No esta, ponemos los datos basicos de rss y bajamos el resto de 'link'
    # si no puedo bajar el contenido no doy de alta el articulo
    soup = BeautifulSoup(urlopen(link))
    title = soup.select('h1')
    contenido = soup.select('div#texto')

    if len(contenido) == 0:
      logging.error('no se puede sacar el contenido de %s' % link)
      return

    art = Article(key_name=artkey)
    art.category  = Category.get_or_insert(self.request.POST.get('category'))
    art.title     = db.Text(arg=title[0].encode_contents().decode('utf-8')) #, encoding='utf-8'  #self.request.POST.get('title')
    art.published = self.to_datetime(self.request.POST.get('published'))
    art.content   = db.Text(arg=contenido[0].encode_contents(), encoding='utf-8') 

    # Bajada
    bajada = soup.select('div#baja h3')
    if len(bajada) == 0:
      bajada = soup.select('h3#baja')
    
    art.excerpt = bajada[0].text if len(bajada) else ''
    
    # Imagen
    imagen = soup.select('div.ImagenesNoticia img.Foto')
    imagen = imagen[0].attrs['src'] if len(imagen) and 'src' in imagen[0].attrs else None

    # La bajamos al blobstore
    if imagen:
      fp = urlopen(imagen)

      # Create the file
      file_name = files.blobstore.create(mime_type=fp.info()['Content-Type'], _blobinfo_uploaded_filename=imagen)

      with files.open(file_name, 'a') as f:
        f.write(fp.read())
      
      files.finalize(file_name)
      
      # Get the file's blob key
      blob_key = files.blobstore.get_blob_key(file_name)

      # ------ BEGIN HACK -------- #
      # GAE BUG => http://code.google.com/p/googleappengine/issues/detail?id=5142
      for i in range(1,10):
        if not blob_key:
          time.sleep(0.05)
          blob_key = files.blobstore.get_blob_key(file_name)
        else:
          break
      
      if not blob_key:
        logging.error("no pude obtener el blob_key, hay un leak en el blobstore!")
        abort(500)
      # ------ END HACK -------- #

      art.image = get_serving_url(blob_key)
    
    # Noticias relacionadas
    
    related_keys = []
    related_news = soup.select(u'a.VinculoTexto')
    for alink in related_news:
      related_keys.append(self.get_link_hash(alink.get('href')))
    
    art.rel_art_keys = related_keys
      
    art.put()
  
  def to_datetime(self, str):
    tmp = parsedate(str)
    return datetime(tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5])


# =======================================================
# =======================================================
class IVCViewer(FrontendHandler):
  def list(self, **kwargs):
    self.request.charset = 'utf-8'
    diarios = DiarioIVC.all()
    return self.render_response('backend/_ivc_diarios.html', diarios=diarios, **kwargs)
			
class IVC(RequestHandler):			
  def download(self, **kwargs):
    items = [
            {'url':u'http://www.ivc.org.ar/consulta?op=f&empresa_id=&tipo_medio_id=1&provincia_id=&medio_edicion_id=&x=38&y=2', 'category':'diarios_pagos'},
            #{'url':u'http://www.ivc.org.ar/consulta?op=f&empresa_id=&tipo_medio_id=2&provincia_id=&medio_edicion_id=&x=38&y=2', 'category':'diarios_gratis'},
            #{'url':u'http://www.ivc.org.ar/consulta?op=f&empresa_id=&tipo_medio_id=3&provincia_id=&medio_edicion_id=&x=38&y=2', 'category':'revistas_pagos'},
            #{'url':u'http://www.ivc.org.ar/consulta?op=f&empresa_id=&tipo_medio_id=4&provincia_id=&medio_edicion_id=&x=38&y=2', 'category':'revistas_gratis'}
          ]
    for item in items:
      taskqueue.add(url='/download/ivc/feed', params={'feed':item['url'], 'category':item['category']})

  def download_feed(self, **kwargs):
    self.request.charset = 'utf-8'
    
    feed = self.request.POST.get('feed')
    category = self.request.POST.get('category')

    soup = BeautifulSoup(urlopen(feed))
    links = soup.select('table.tabla-interna td.tabla-interna a')
    
    for item in links:
      params = {
        'category'  : category,
        'link'      : u'http://www.ivc.org.ar'+item.get('href')
      }

      taskqueue.add(url='/download/ivc/article', params=params)

  def get_link_hash(self, link):
    return hashlib.sha1(link).hexdigest()
    
  
  def download_article(self, **kwargs):
    self.request.charset = 'utf-8'
    
    link        = self.request.POST.get('link')
    #link   = u'http://www.ivc.org.ar/consulta?op=c&asociado_id=78'
    
    soup = BeautifulSoup(urlopen(link))
    
    medio = DiarioIVC()
    
    datos_medio       = soup.select('#datos_medio td.tabla-interna')
    
    medio.ivc_url           = link
    
    medio.nombre            = datos_medio[0].text
    medio.razon_social      = datos_medio[1].text
    medio.domicilio         = datos_medio[2].text
    medio.localidad         = datos_medio[3].text
    medio.provincia         = datos_medio[4].text
    medio.telefono          = datos_medio[5].text
    medio.email             = datos_medio[6].text
    medio.web               = datos_medio[7].text
    medio.categoria         = self.request.POST.get('category')
    
    tipos_promedio       = soup.findAll('td', colspan="3")
    index=0
    # for tipo_promedio_item in tipos_promedio:
      # m = Kato()
      # m.url     = link
      # m.nombre  = tipo_promedio_item.text
      # m.index   = index
      # index+=1
      # m.put()
      # continue
    # return
    
    if len(tipos_promedio)>0:
      promedio = tipos_promedio[0].parent.parent.parent.findAll('td')
      marca = False
      datillos = []
      for promedio_item in promedio:
        if marca:
          datillos.append(promedio_item.text)
          marca=False
          continue
        if promedio_item.text == 'Promedio':
          marca=True
      
      index=0    
      for tipo_promedio in tipos_promedio:
        setattr(medio, do_slugify(tipo_promedio.text).replace('-', '_'), float(datillos[index].replace('.', '')));
        index+=1
    
    medio.put()
  
  
# =======================================================
# =======================================================
class ElDiaRSS(RequestHandler):
  def download(self, **kwargs):
    items = [
            '1_162052',
            '1_162083',
            '0_391700',
            '1_162089',
            '1_162098',
            '1_162081',
            '1_162086',
            '1_162082',
            '1_162090',
            '1_162060',
            '1_162094',
            '1_162051',
            '1_162099',
            '0_391716',
            '0_391751',
            '1_162063',
            '1_162070',
            '1_162079',
            '0_391698',
            '0_391706',
            '1_162097',
            '0_391766',
            '1_162095',
            '1_162061',
            '1_162091',
            '1_162071',
            '0_391681',
            '1_162096',
            '1_162093',
            '1_162069',
            '1_162058',
            '0_391682',
            '0_391684',
            '1_162092',
            '1_162074',
            '0_391688',
            '0_391675',
            '0_391677',
            '0_391679',
            '1_162050',
            '1_162053',
            '1_162072',
            '1_162080',
            '0_391633',
            '0_391687',
            '1_162064',
            '1_162067',
            '1_162077',
            '0_391669',
            '1_162085',
            '0_391667',
            '0_391710',
            '0_391683',
            '0_391707',
            '0_391714',
            '0_391718',
            '1_162049',
            '1_162048',
            '0_391629',
            '0_391631',
            '1_162073',
            '1_162059',
            '1_162087',
            '1_162088' 
            ]
    
    for item in items:
      taskqueue.add(url='/check/eldia_gallery/feed', params={'id':item})

  def download_feed(self, **kwargs):
    self.request.charset = 'utf-8'
    
    id = self.request.POST.get('id')
    url = u'http://www.eldia.com.ar/rss/noticia.aspx?id=%s' % id
    
    d = feedparser.parse(url)
    
    for item in d['items']:
      
      art = ArticlesGallery()
      art.id  = id
      art.url = url
      art.has_gallery = 0
      if item.has_key('media_group'):
        has_gallery=1
      #art.rss   = d['feed'] 
      art.put()