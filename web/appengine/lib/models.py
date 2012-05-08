# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db, blobstore
from google.appengine.api.images import get_serving_url

cats = [ 
          {'key': 'deportes',  'count': 10, 'desc': 'Deportes',  'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=8' , 'type':'seccion'},
          {'key': 'economia',  'count': 3, 'desc': u'Economía',  'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=6', 'type':'seccion'},
          {'key': 'mundo',     'count': 3, 'desc': 'El Mundo',   'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=4', 'type':'seccion'},
          {'key': 'pais',      'count': 3, 'desc': u'El País',   'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=3', 'type':'seccion'},
          {'key': 'ciudad',    'count': 3, 'desc': 'La Ciudad',  'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=1', 'type':'seccion'},
          {'key': 'policiales', 'count': 3, 'desc': 'Policiales', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=5', 'type':'seccion'},
        
          {'key': 'educacion', 'count': 3, 'desc': u'Educación', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=19', 'type':'seccion'},
          {'key': 'espectaculos', 'count': 3, 'desc': u'Espectáculos', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=7', 'type':'seccion'},
          {'key': 'infogral', 'count': 3, 'desc': u'Información General', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=10', 'type':'seccion'},
          {'key': 'provincia', 'count': 3, 'desc': 'La Provincia', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=2', 'type':'seccion'},
          
          {'key': 'deco', 'count': 3, 'desc': u'DECO', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=20', 'type':'suplemento'},
          {'key': 'joven', 'count': 3, 'desc': u'Jóven', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=21', 'type':'suplemento'},
          {'key': 'moda', 'count': 3, 'desc': u'Moda', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=22', 'type':'suplemento'},
          {'key': 'pesca', 'count': 3, 'desc': u'Pesca', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=23', 'type':'suplemento'},
          {'key': 'revista', 'count': 3, 'desc': u'Revista', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=24', 'type':'suplemento'},
          {'key': 'septimo', 'count': 3, 'desc': u'Séptimo Día', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=25', 'type':'suplemento'},
          {'key': 'rugby', 'count': 3, 'desc': u'Suplemento Rugby', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=42', 'type':'suplemento'},
          {'key': 'zonanorte', 'count': 3, 'desc': u'Zona Norte', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=34', 'type':'suplemento'},
          {'key': 'coctelera', 'count': 3, 'desc': u'La Coctelera', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=49', 'type':'suplemento'},
          {'key': 'mujer', 'count': 3, 'desc': u'Mujer', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=500', 'type':'suplemento'},
          {'key': 'cubo', 'count': 3, 'desc': u'CUBO', 'feed':'http://www.eldia.com.ar/rss/rss.aspx?ids=501', 'type':'suplemento'},
          
          {'key': 'automotores', 'count': 3, 'desc': u'Automotores', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=7', 'type':'servicio'},
          {'key': 'alquiler_inmuebles', 'count': 3, 'desc': u'Alquiler de inmuebles', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=2', 'type':'servicio'},
          {'key': 'venta_inmuebles', 'count': 3, 'desc': u'Compra y venta de inmuebles', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=4', 'type':'servicio'},
          {'key': 'cupones', 'count': 3, 'desc': u'Cupones de descuento', 'feed':u'#', 'type':'servicio'},
          
          {'key': 'festejos', 'count': 3, 'desc': u'Festejos y guarderías', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=15', 'type':'servicio'},
                    
          {'key': 'farmacias', 'count': 3, 'desc': u'Farmacias de turno', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=1', 'type':'servicio'},
          #{'key': 'farmacias_1', 'count': 3, 'desc': u'Farmacias de turno hasta 8:30', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=1', 'type':'servicio'},
          #{'key': 'farmacias_2', 'count': 3, 'desc': u'Farmacias de turno desde 8:30', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=2', 'type':'servicio'},
           
          {'key': 'telefonos', 'count': 3, 'desc': u'Teléfonos útiles', 'feed':'http://www.eldia.com.ar/varios/telefonos.aspx', 'type':'servicio'}
            
          
        ]
          
        
          
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
