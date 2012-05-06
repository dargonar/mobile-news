# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db, blobstore
from google.appengine.api.images import get_serving_url

class NewsPaper(db.Model):
  name         = db.StringProperty()

class Category(db.Model):
  name         = db.StringProperty()

class Article(db.Model):
  category          = db.ReferenceProperty(Category)
  title             = db.StringProperty(indexed=False, multiline=True)
  excerpt           = db.StringProperty(indexed=False, multiline=True)
  image             = db.StringProperty(indexed=False)
  published         = db.DateTimeProperty()
  content           = db.TextProperty()
  rel_art_keys      = db.StringListProperty()
  created_at        = db.DateProperty(auto_now_add=True)
