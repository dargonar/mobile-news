# -*- coding: utf-8 -*-
from webapp2 import Route


def get_rules():
    
    rules = [
      Route('/',                        name='mvp/index',               handler='apps.mvp_1.handlers.Index'),
      Route('/demo',                    name='mvp/demo',               handler='apps.mvp_1.handlers.Index:demo'),
    ]
    
    return rules
