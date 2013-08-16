# -*- coding: utf-8 -*-
import logging

from google.appengine.ext import db, blobstore
from google.appengine.api.images import get_serving_url

from datetime import date, datetime , timedelta

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
          
          {'key': 'automotores', 'count': 3, 'desc': u'Automotores', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=7', 'type':'clasificado'},
          {'key': 'alquiler_inmuebles', 'count': 3, 'desc': u'Alquiler de inmuebles', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=2', 'type':'clasificado'},
          {'key': 'venta_inmuebles', 'count': 3, 'desc': u'Compra y venta de inmuebles', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=4', 'type':'clasificado'},
          {'key': 'cupones', 'count': 3, 'desc': u'Cupones de descuento', 'feed':u'#', 'type':''},
          
          {'key': 'festejos', 'count': 3, 'desc': u'Festejos y guarderías', 'feed':'http://www.eldia.com/mc/clasi_rss.aspx?idr=15', 'type':'clasificado'},
                    
          {'key': 'farmacias', 'count': 3, 'desc': u'Farmacias de turno', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=1', 'type':'servicio'},
          #{'key': 'farmacias_1', 'count': 3, 'desc': u'Farmacias de turno hasta 8:30', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=1', 'type':'servicio'},
          #{'key': 'farmacias_2', 'count': 3, 'desc': u'Farmacias de turno desde 8:30', 'feed':'http://www.eldia.com.ar/movil/turnos.aspx?IdT=2', 'type':'servicio'},
           
          {'key': 'telefonos', 'count': 3, 'desc': u'Teléfonos útiles', 'feed':'http://www.eldia.com.ar/varios/telefonos.aspx', 'type':'servicio'},
          {'key': 'transito', 'count': 3, 'desc': u'Estado del tránsito', 'feed':'#', 'type':'servicio'},
          {'key': 'meteorologia', 'count': 3, 'desc': u'Pronóstico meteorológico', 'feed':'#', 'type':'servicio'}
            
          
        ]
          

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

class DiarioIVC(db.Model):
  nombre            = db.StringProperty(indexed=False)
  razon_social      = db.StringProperty(indexed=False)
  domicilio         = db.StringProperty(indexed=False)
  localidad         = db.StringProperty(indexed=False)
  provincia         = db.StringProperty(indexed=False)
  telefono          = db.StringProperty(indexed=False)
  email             = db.StringProperty(indexed=False)
  web               = db.StringProperty(indexed=False)
  promedio          = db.StringProperty(indexed=False)
  promedio_titulo   = db.StringProperty(indexed=False)
  categoria         = db.StringProperty(indexed=False)
  # Circ. Neta Pagada Domingo
  circ_neta_pagada_domingo            = db.FloatProperty(indexed=False)
  # Circ. Neta Pagada Lunes a Domingo
  circ_neta_pagada_lunes_a_domingo    = db.FloatProperty(indexed=False)
  # Lunes a Viernes
  lunes_a_viernes                     = db.FloatProperty(indexed=False)
  # Lunes a Sabado
  lunes_a_sabado                      = db.FloatProperty(indexed=False)
  # Bloque
  bloque                              = db.FloatProperty(indexed=False)
  # Circulacion neta pagada
  circulacion_neta_pagada             = db.FloatProperty(indexed=False)  
  # Individualizada
  individualizada                     = db.FloatProperty(indexed=False)
  ivc_url           = db.StringProperty(indexed=False)
  
class Kato(db.Model):
  nombre            = db.StringProperty()
  url               = db.StringProperty()
  index             = db.IntegerProperty()
  
class ArticlesGallery(db.Model):
  id                = db.StringProperty()
  url               = db.StringProperty()
  has_gallery       = db.IntegerProperty()
  rss           = db.TextProperty()

class CachedContent(db.Model):
  content            = db.TextProperty()
  inner_url          = db.StringProperty()
  created_at         = db.DateTimeProperty(auto_now_add=True)

class RegisteredEditor(db.Model):
  created_at         = db.DateTimeProperty(auto_now_add=True)
  name               = db.StringProperty(indexed=False)
  email              = db.EmailProperty()
  telephone          = db.StringProperty(indexed=False)
  mobile             = db.StringProperty(indexed=False)
  call_at            = db.StringProperty(indexed=False)
  message            = db.StringProperty(indexed=False)
  website            = db.StringProperty(indexed=False)
  
  def __repr__(self):
    return 'RegisteredEditor: ' + self.email