# -*- coding: utf-8 -*-
from collections import OrderedDict

def get_mapping():
  return {
  'pregon' : {
    'httpurl' : OrderedDict([
      ('section://main' , 'X: pregon.rss_index') ,
      ('noticia://'     , 'X: pregon.rss_noticia') ,
      ('section://'     , 'X: pregon.rss_section') ,
      ('menu://'        , 'X: pregon.rss_menu') ,
      ('funebres://'    , 'X: pregon.rss_funebres') ,
    ]), 
    'templates-small': OrderedDict([
      ('section://main' , {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'}),
      ('noticia://'     , {'pt': '3_new.xsl',          'ls': '3_new.xsl'}),
      ('section://'     , {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'}),
      ('menu://'        , {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'}),
      ('funebres://'    , {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'}),
    ]),
    'templates-big': OrderedDict([
      ('section://main'          , {'pt': '1_tablet_main_list.xsl',                  'ls': '1_tablet_main_list.xsl'}),
      
      ('menu_section://main'     , {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_portrait.xsl'}),
      ('menu://'                 , {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'}),
      ('section://'              , {'pt': '1_tablet_section_list.xsl',               'ls': '1_tablet_section_list.xsl'}),
      ('noticia://'              , {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'}),
      
      ('ls_menu_section://main'  , {'pt': '2_tablet_noticias_index_landscape.xsl',   'ls': '2_tablet_noticias_index_landscape.xsl'}),
      ('ls_menu_section://'      , {'pt': '2_tablet_noticias_seccion_landscape.xsl', 'ls': '2_tablet_noticias_seccion_landscape.xsl'}),
      ('ls_section://'           , {'pt': '2_section_list.xsl',                      'ls': '2_section_list.xsl'}),
      ('ls_noticia://'           , {'pt': '3_tablet_new_landscape.xsl',              'ls': '3_tablet_new_landscape.xsl'}),

      ('funebres://'             , {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'}),
    ]),
    'extras': {
      'has_clasificados' : False,
      'has_funebres'     : True,
      'has_farmacia'     : False,
      'has_cartelera'    : False,
    }, 
  }
}