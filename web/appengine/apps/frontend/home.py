# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category
from utils import MyBaseHandler, get_or_404

class Index(MyBaseHandler):
  def get(self, **kwargs):

    cats = [ {'key': 'deportes',  'count': 10, 'desc': 'Deportes'},
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
    rel_articles = []
    if len(article.rel_art_keys)>0:
      rel_articles_keys = []
      for key in article.rel_art_keys:
        rel_articles.append( Article(key_name=key) )
        #rel_articles_keys.append(db.Key.from_path('Article',key))
      #rel_articles = db.get(rel_articles_keys)
    return self.render_response('frontend/_article.html', article=article, rel_articles = rel_articles)
    
class Test(MyBaseHandler):
  def get(self, **kwargs):
    from urllib2 import urlopen
    from bs4 import BeautifulSoup
    
    soup = BeautifulSoup(u'<table><tr><td><a class="VinculoTexto" href="http://www.eldia.com.ar/edis/20120505/cacho-alvarez-nego-chispazos-entre-campora-juan-domingo-20120505115008.htm">"Cacho" &#193;lvarez neg&#243; chispazos entre La C&#225;mpora y La Juan Domingo<br /></a></td></tr></table>', from_encoding="utf-8")
    
    related_news = soup.select(u'a.VinculoTexto')
    
    s=''
    for alink in related_news:
      link = alink.get('href')
      s+=alink.get_text() #.encode("utf-8") 
      s+=link
      s+=self.get_link_hash(link)

    self.response.write(str(len(related_news))+'|'+s)
    
  def get_link_hash(self, link):
    import hashlib
    return hashlib.sha1(link).hexdigest()
      
    