# -*- coding: utf-8 -*-
from webapp2 import Route

def get_rules():
    
    rules = [
      Route('/download/eldia'   ,  name='backend/download'        , handler='apps.backend.download.ElDia:download'),
      Route('/download/feed'    ,  name='backend/download_feed'   , handler='apps.backend.download.ElDia:download_feed'),
      Route('/download/article' ,  name='backend/download_article', handler='apps.backend.download.ElDia:download_article'),
    ]
    
    return rules
