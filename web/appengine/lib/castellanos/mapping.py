# -*- coding: utf-8 -*-
from collections import OrderedDict

def get_mapping():
  return {
  'castellanos' : {
    'httpurl' : OrderedDict([
      ('section://main'        , 'X: castellanos.rss_index' ),
      ('noticia://'            , 'X: castellanos.rss_noticia'),
      ('section://'            , 'X: castellanos.rss_seccion'),
      ('clasificados://'       , ''),
      ('menu://'               , 'X: castellanos.rss_menu' ),
      ('funebres://'           , 'X: castellanos.rss_funebres' ),
      ('farmacia://'           , 'http://www.eldia.com.ar/extras/farmacias_txt.aspx'),
      ('cartelera://'          , 'http://www.eldia.com.ar/extras/carteleradecine_txt.aspx'),
      
      ('menu_section://main'   , 'X: castellanos.rss_index' ),
      ('menu_section://'       , 'X: castellanos.rss_seccion' ),
    ]), 
    'templates-small': OrderedDict([
      ('section://main'  , {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'}),
      ('noticia://'      , {'pt': '3_new.xsl',          'ls': '3_new.xsl'}),
      ('section://'      , {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'}),
      ('clasificados://' , {'pt': '5_clasificados.xsl', 'ls': '5_clasificados.xsl'}),
      ('menu://'         , {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'}),
      ('funebres://'     , {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'}),
      ('farmacia://'     , {'pt': '7_farmacias.xsl',    'ls': '7_farmacias.xsl'}),
      ('cartelera://'    , {'pt': '8_cartelera.xsl',    'ls': '8_cartelera.xsl'}),
    ]),
    'templates-big': OrderedDict([
      ('section://main'          , {'pt': '1_tablet_main_list.xsl',                  'ls': '1_tablet_main_list.xsl'}),
      
      ('menu://'                 , {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'}),
      ('section://'              , {'pt': '1_tablet_section_list.xsl',               'ls': '1_tablet_section_list.xsl'}),
      ('noticia://'              , {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'}),
      
      # 'menu_section://main'     : {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_portrait.xsl'},
      # 'menu_section://'         : {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_index_portrait.xsl'},
      #('ls_menu_section://main'   , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',    'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      ('ls_menu_section://'       , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',    'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      #('menu_section://main'      , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',    'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      ('menu_section://'          , {'pt': '2_tablet_noticias_portrait_en_nota_abierta.xsl',    'ls': '2_tablet_noticias_landscape_en_nota_abierta.xsl'}),
      # 'ls_menu_section://main'  : {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_landscape.xsl'},
      # 'ls_menu_section://'      : {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_seccion_landscape.xsl'},
      
      # ('ls_section://'           , {'pt': '2_section_list.xsl',                      'ls': '2_section_list.xsl'}),
      # ('ls_noticia://'           , {'pt': '3_tablet_new_landscape.xsl',              'ls': '3_tablet_new_landscape.xsl'}),

      ('clasificados://'         , {'pt': '5_tablet_clasificados.xsl',               'ls': '5_tablet_clasificados.xsl'}), 
      ('funebres://'             , {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'}),
      ('farmacia://'             , {'pt': '7_tablet_farmacias.xsl',                  'ls': '7_tablet_farmacias.xsl'}),
      ('cartelera://'            , {'pt': '8_tablet_cartelera.xsl',                  'ls': '8_tablet_cartelera.xsl'}),
      
      # 'noticia://'      : {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'},
      # 'section://'      : {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_seccion_landscape.xsl'},
      # 'clasificados://' : {'pt': '5_tablet_clasificados.xsl',               'ls': '5_tablet_clasificados.xsl'},
      # 'menu://'         : {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'},
      # 'funebres://'     : {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'},
      # 'farmacia://'     : {'pt': '7_tablet_farmacias.xsl',                  'ls': '7_tablet_farmacias.xsl'},
      # 'cartelera://'    : {'pt': '8_tablet_cartelera.xsl',                  'ls': '8_tablet_cartelera.xsl'},
    ]),
    'extras': OrderedDict([
      ('has_clasificados' , False),
      ('has_funebres'     , True),
      ('has_farmacia'     , True),
      ('has_cartelera'    , True),
    ])
  }
}      