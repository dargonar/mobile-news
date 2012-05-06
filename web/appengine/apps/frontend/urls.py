# -*- coding: utf-8 -*-
from webapp2 import Route


def get_rules():
    
    rules = [
      Route('/', name='frontend/home', handler='apps.frontend.home.Index'),
      Route('/test', name='frontend/test', handler='apps.frontend.home.Test'),
      Route('/view/<article>', name='frontend/article', handler='apps.frontend.home.ViewArticle'),
    ]
    
    return rules
