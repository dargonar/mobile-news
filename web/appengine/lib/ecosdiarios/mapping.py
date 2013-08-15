# -*- coding: utf-8 -*-
from collections import OrderedDict

def get_mapping():
  return {
  'ecosdiarios' : {
    'httpurl' : OrderedDict([
      ('section://main' , 'X: ecosdiarios.rss_index') ,
      ('noticia://'     , 'X: ecosdiarios.rss_noticia') ,
      ('section://'     , 'X: ecosdiarios.rss_section') ,
      ('menu://'        , 'X: ecosdiarios.rss_menu') ,
      ('farmacia://'    , 'X: ecosdiarios.rss_farmacia') ,
    ]), 
    'templates-small': OrderedDict([
      ('section://main' , {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'}),
      ('noticia://'     , {'pt': '3_new.xsl',          'ls': '3_new.xsl'}),
      ('section://'     , {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'}),
      ('menu://'        , {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'}),
      ('farmacia://'    , {'pt': '7_farmacias.xsl',    'ls': '7_farmacias.xsl'}),
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
      'has_funebres'     : False,
      'has_farmacia'     : True,
      'has_cartelera'    : False,
    }, 
  }
}