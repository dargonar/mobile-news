# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category
from utils import MyBaseHandler, get_or_404

class Index(MyBaseHandler):
  def get(self, **kwargs):

    cats = { 'deportes'   : 2,
             'economia'   : 2,
             'mundo'      : 2,
             'pais'       : 2,
             'ciudad'     : 2}

    catitems = []
    for cat in cats:
      catitems.append( Article
        .all()
        .filter('category', db.Key.from_path('Category',cat))
        .order('-published')
        .fetch(cats[cat]) )

    return self.render_response('frontend/_home.html', catitems=catitems)

class ViewArticle(MyBaseHandler):
  def get(self, **kwargs):

    article = get_or_404(kwargs['article'])
    return self.render_response('frontend/_article.html', article=article)