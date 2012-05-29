# -*- coding: utf-8 -*-
from webapp2 import Route
from webapp2_extras.routes import PathPrefixRoute

def get_rules():
    
    rules = [
      PathPrefixRoute('/demo/service', [
        Route('/',                        name='frontend/home',               handler='apps.frontend.home.Index'),
        Route('/fullversion',             name='frontend/home/fullversion',   handler='apps.frontend.home.Index:fullversion'),
        Route('/view/<article>',          name='frontend/article',            handler='apps.frontend.home.ViewArticle'),
        Route('/m/secciones',             name='frontend/secciones',          handler='apps.frontend.home.ListSecciones'),
        #Route('/m/secciones/<category>',  name='frontend/secciones/category', handler='apps.frontend.home.SeccionArticles'),
        Route('/m/secciones/<category>',  name='frontend/secciones/category', handler='apps.frontend.home.Index:get_seccion_articles'),
        Route('/m/servicios',             name='frontend/servicios',          handler='apps.frontend.home.ListServicios'),
        Route('/m/clasificados',          name='frontend/clasificados',       handler='apps.frontend.home.ListClasificados'),
        Route('/m/clasificados/automotores',          name='frontend/clasificados/automotores',       handler='apps.frontend.home.ListClasificados:automotores'),
        Route('/m/suplementos',           name='frontend/suplementos',        handler='apps.frontend.home.ListSuplementos'),
        Route('/m/perfil',                name='frontend/perfil',             handler='apps.frontend.home.Profile'),
        Route('/diarios/csv',             name='frontend/csv',                handler='apps.frontend.home.DiariosCsv'),
      ])
    ]
    
    return rules
