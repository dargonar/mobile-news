# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db

from models import Article, Category, cats, DiarioIVC
from utils import FrontendHandler, get_or_404

class Index(FrontendHandler):
  def get(self, **kwargs):
    return self.render_response('mvp_1/_index.html')
  
  def demo(self, **kwargs):
    return self.render_response('mvp_1/_demo.html')
  
