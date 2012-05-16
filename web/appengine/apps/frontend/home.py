# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category, cats
from utils import MyBaseHandler, get_or_404

class Index(MyBaseHandler):
  page_count = 10
  def get(self, **kwargs):
    return self.build_response(None)
    
    
  def get_seccion_articles(self, **kwargs):
    # catitems = []
    # catitems.append( Article
                # .all()
                # .filter('category', db.Key.from_path('Category',kwargs['category']))
                # .order('-published')
                # .fetch(20) )
    # cats_conf=(dict((cat['key'], cat['desc']) for cat in cats))
    # return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=cats_conf, the_category=cats_conf[kwargs['category']])
    return self.build_response(kwargs['category'])
    
  def build_response(self, category):
    
    this_cursor = self.request.GET.get('more_cursor', None)
    
    if this_cursor is not None and len(str(this_cursor))<1:
      this_cursor=None
      
    query = Article.all()
    
    cats_conf=(dict((cat['key'], cat['desc']) for cat in cats))
    
    the_category = None
    if category is not None:
      _category = db.Key.from_path('Category',category)
      query.filter('category', _category)
      the_category = cats_conf[category]
      
    if this_cursor is not None:
      query.with_cursor(this_cursor)
    
    catitems = query.order('-published').fetch(self.page_count)
    
    # catitems.append( Article
      # .all()
      # .order('-published')
      # .fetch(50))
    more_cursor=''
    if len(catitems) == self.page_count:
      more_cursor = query.cursor()
  
    if this_cursor is not None:
      html    = self.render_template('frontend/_articles.html', catitems=catitems, cats_conf=cats_conf)
      return self.render_json_response({
          'html': html,
          'more_cursor': more_cursor})
          
    return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=cats_conf, the_category=the_category, the_category_id=category, this_cursor=this_cursor, more_cursor = more_cursor )
  
  
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

# class SeccionArticles(MyBaseHandler):
  # def get(self, **kwargs):
    # catitems = []
    # catitems.append( Article
                # .all()
                # .filter('category', db.Key.from_path('Category',kwargs['category']))
                # .order('-published')
                # .fetch(20) )
    # cats_conf=(dict((cat['key'], cat['desc']) for cat in cats))
    # return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=cats_conf, the_category=cats_conf[kwargs['category']])

class ListServicios(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_servicios.html', cats=cats)
    
class ListSuplementos(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_suplementos.html', cats=cats)

class Profile(MyBaseHandler):
  def get(self, **kwargs):
    return self.render_response('frontend/_profile.html')