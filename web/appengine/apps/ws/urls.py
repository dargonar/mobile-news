# -*- coding: utf-8 -*-
from webapp2 import Route
from webapp2_extras.routes import PathPrefixRoute, NamePrefixRoute, HandlerPrefixRoute

def get_rules():
    
    rules = [
      
        PathPrefixRoute('/ws', [ NamePrefixRoute('ws-', [ HandlerPrefixRoute('apps.ws.ScreenController', [
          Route('/screen',   name='get_screen',   handler='.ScreenController:get_screen'),
        ]) ]) ]),

    ]
    
    return rules
