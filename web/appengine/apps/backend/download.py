# -*- coding: utf-8 -*-
import logging
import feedparser
import hashlib

from email.utils import parsedate
from datetime import datetime

from urllib2 import urlopen
from bs4 import BeautifulSoup

from google.appengine.api import files, taskqueue

from google.appengine.ext import db, blobstore
from google.appengine.api.images import get_serving_url

from webapp2 import RequestHandler
from models  import Category, Article, cats as feeds

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
    art.title     = db.Text(arg=title[0].encode_contents().encode('utf-8'), encoding='utf-8')  #self.request.POST.get('title')
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

