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

from apps.ws.ScreenController import pre_build_html_and_images


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

    # Armamos el html de la seccion
    

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
    #index=0
    for i in xml.rss.channel.item:
      #logging.error('----> a bajar section ' + i.guid.value)
      taskqueue.add(queue_name='download', url='/download/section', params={'appid': appid, 'section': i.guid.value})
      #if index==3:
      #  break
      #index=index+1
      
    # Refrescamos el main
    taskqueue.add(queue_name='download', url='/download/section', params={'appid': appid, 'section': 'main'})

  def download_all(self, **kwargs):    
    # Mantenemos una lista de lo que fuimos mandando a bajar
    # por que hay dos appid para ElDia (x ej)
    inverted = dict((v,k) for k,v in apps_id.iteritems())
    for name, appid in inverted.items():
      if name != 'pregon': continue
      #logging.error('----> a bajar newspaper ' + appid)
      taskqueue.add(queue_name='download', url='/download/newspaper', params={'appid':appid})
      break