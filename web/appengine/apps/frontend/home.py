# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category, cats
from utils import MyBaseHandler, get_or_404

class Index(MyBaseHandler):
  def get(self, **kwargs):

    catitems = []
    for cat in cats:
      if cat['type']!='seccion':
        continue
      catitems.append( Article
        .all()
        .filter('category', db.Key.from_path('Category',cat['key']))
        .order('-published')
        .fetch(cat['count']) )
    
    # catitems.append( Article
      # .all()
      # .order('-published')
      # .fetch(50))
        
    return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=(dict((cat['key'], cat['desc']) for cat in cats)), the_category=None )

class ViewArticle(MyBaseHandler):
  def get(self, **kwargs):

    article = get_or_404(kwargs['article'])
    rel_articles = []
    if len(article.rel_art_keys)>0:
      rel_articles_keys = []
      for key in article.rel_art_keys:
        #rel_articles.append( Article(key_name=key) )
        rel_articles.append( db.get(db.Key.from_path('Article',key)))
    return self.render_response('frontend/_article.html', article=article, rel_articles = rel_articles)
    
class ListSecciones(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_secciones.html', cats=cats)

class SeccionArticles(MyBaseHandler):
  def get(self, **kwargs):
    catitems = []
    catitems.append( Article
                .all()
                .filter('category', db.Key.from_path('Category',kwargs['category']))
                .order('-published')
                .fetch(20) )
    cats_conf=(dict((cat['key'], cat['desc']) for cat in cats))
    return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=cats_conf, the_category=cats_conf[kwargs['category']])

class ListServicios(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_servicios.html', cats=cats)
    
class ListSuplementos(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_suplementos.html', cats=cats)

class Profile(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_profile.html')