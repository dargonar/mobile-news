# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from urllib2 import urlopen
from datetime import datetime, timedelta
from collections import OrderedDict
from hashlib import sha1

import logging
import cgi
import re
import StringIO

from utils import get_header, get_footer

def get_xml(kwargs):
  
  output = StringIO.StringIO()
  output.write(get_header())

  def output_write(strx):
    output.write(u'\t' + strx + u'\n')

  def print_item(title, id):
    output_write( u'<item>')
    output_write( u'<title>%s</title>' % title )
    output_write( u'<description>desc</description>')
    output_write( u'<link isPermaLink="false">clasificados://%s</link>' % id )
    output_write( u'<guid>%s</guid>' % id )
    output_write( u'<pubDate></pubDate>')
    output_write( u'<author></author>' )
    output_write( u'<category></category>')
    output_write( u'</item>')
  
  menu = get_classifieds()
  for key,value in menu.items():
    print_item(value, key)
  output.write(get_footer())

  return output.getvalue()

def get_classifieds():
  return OrderedDict([
  ('0', u'Salud'),
  ('1', u'Alquiler de habitaciones'),
  ('2', u'Alquiler de inmuebles'),
  ('3', u'Geriátricos y pensiones'),
  ('4', u'Compra y venta de inmuebles'),
  ('5', u'Compra venta y alquiler de neg. ped. socios'),
  ('6', u'Veterinarias, mascotas'),
  ('7', u'Compra y venta de automotores'),
  ('8', u'Compra y venta de motos y accesorios'),
  ('9', u'Transportes'),
  ('10', u'Compra y venta art. del hogar (usados)'),
  ('11', u'Electrónica, música, equipos  y fotografía'),
  ('12', u'Construccio-nes, planos y empresas'),
  ('13', u'Albañilería, pintura, plomería, rep. techos'),
  ('14', u'Hipotecas, prestamos, transferencias y seguros'),
  ('15', u'Festejos y guarderías'),
  ('16', u'Enseñanza de idiomas y traducciones'),
  ('17', u'Enseñanza particular'),
  ('18', u'Máquinas de coser, tejer, escribir y calcular'),
  ('19', u'Materiales de construcción'),
  ('20', u'Modistas, sastres, talleres, arreglos ropa'),
  ('21', u'Oficios ofrecidos'),
  ('22', u'Empleos'),
  ('23', u'Tarot - astrología - parapsicología'),
  ('24', u'Extravios y hallazgos'),
  ('25', u'Personas buscadas'),
  ('26', u'Personal casa flia. ofrecidos'),
  ('27', u'Personal casa flia. pedidos'),
  ('28', u'Service de art. del hogar reparaciones'),
  ('29', u'Varios'),
  ('30', u'Art. suntuarios, alhajas, oro'),
  ('31', u'Cursos varios'),
  ('32', u'Deportes y camping'),
  ('33', u'Remates, demoliciones'),
  ('34', u'Jardinería, plantas y viveros'),
  ('35', u'Carpintería metalica y madera, puertas, cortinas'),
  ('36', u'Ferreterías - cerrajerías')
  ])
