# -*- coding: utf-8 -*-
from webapp2 import Route


def get_rules():
    
    rules = [
      Route('/',                        name='frontend/home',               handler='apps.frontend.home.Index'),
      Route('/view/<article>',          name='frontend/article',            handler='apps.frontend.home.ViewArticle'),
      Route('/m/secciones',             name='frontend/secciones',          handler='apps.frontend.home.ListSecciones'),
      #Route('/m/secciones/<category>',  name='frontend/secciones/category', handler='apps.frontend.home.SeccionArticles'),
      Route('/m/secciones/<category>',  name='frontend/secciones/category', handler='apps.frontend.home.Index:get_seccion_articles'),
      Route('/m/servicios',             name='frontend/servicios',          handler='apps.frontend.home.ListServicios'),
      Route('/m/suplementos',           name='frontend/suplementos',        handler='apps.frontend.home.ListSuplementos'),
      Route('/m/perfil',                name='frontend/perfil',             handler='apps.frontend.home.Profile'),
    ]
    
    return rules
