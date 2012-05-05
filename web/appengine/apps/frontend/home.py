# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category
from utils import MyBaseHandler, get_or_404

class Index(MyBaseHandler):
  def get(self, **kwargs):

    cats = [ {'key': 'deportes',  'count': 3, 'desc': 'Deportes'},
             {'key': 'economia',  'count': 3, 'desc': u'Economía'},
             {'key': 'mundo',     'count': 3, 'desc': 'Mundo'},
             {'key': 'pais',      'count': 3, 'desc': u'País'},
             {'key': 'ciudad',    'count': 3, 'desc': 'Ciudad'}]

    catitems = []
    for cat in cats:
      catitems.append( Article
        .all()
        .filter('category', db.Key.from_path('Category',cat['key']))
        .order('-published')
        .fetch(cat['count']) )
    
    # catitems.append( Article
      # .all()
      # .order('-published')
      # .fetch(50))
        
    return self.render_response('frontend/_home.html', catitems=catitems, cats_conf=(dict((cat['key'], cat['desc']) for cat in cats)) )

class ViewArticle(MyBaseHandler):
  def get(self, **kwargs):

    article = get_or_404(kwargs['article'])
    return self.render_response('frontend/_article.html', article=article)