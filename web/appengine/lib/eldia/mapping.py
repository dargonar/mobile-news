# -*- coding: utf-8 -*-
def get_mapping():
  return {
  'eldia' : {
    'httpurl' : {
      'section://main'  : 'http://www.eldia.com.ar/rss/index.aspx' ,
      'noticia://'      : 'http://www.eldia.com.ar/rss/noticia.aspx?id=%s',
      'section://'      : 'http://www.eldia.com.ar/rss/index.aspx?seccion=%s',
      'clasificados://' : 'http://www.eldia.com.ar/mc/clasi_rss_utf8.aspx?idr=%s&app=1',
      'menu://'         : 'http://www.eldia.com.ar/rss/secciones.aspx',
      'funebres://'     : 'http://www.eldia.com.ar/mc/fune_rss_utf8.aspx',
      'farmacia://'     : 'http://www.eldia.com.ar/extras/farmacias_txt.aspx',
      'cartelera://'    : 'http://www.eldia.com.ar/extras/carteleradecine_txt.aspx',
    }, 
    'templates-small': {
      'section://main'  : {'pt': '1_main_list.xsl',    'ls': '1_main_list.xsl'},
      'noticia://'      : {'pt': '3_new.xsl',          'ls': '3_new.xsl'},
      'section://'      : {'pt': '2_section_list.xsl', 'ls': '2_section_list.xsl'},
      'clasificados://' : {'pt': '5_clasificados.xsl', 'ls': '5_clasificados.xsl'},
      'menu://'         : {'pt': '4_menu.xsl',         'ls': '4_menu.xsl'},
      'funebres://'     : {'pt': '6_funebres.xsl',     'ls': '6_funebres.xsl'},
      'farmacia://'     : {'pt': '7_farmacias.xsl',    'ls': '7_farmacias.xsl'},
      'cartelera://'    : {'pt': '8_cartelera.xsl',    'ls': '8_cartelera.xsl'},
    },
    'templates-big': {
      'section://main'          : {'pt': '1_tablet_main_list.xsl',                  'ls': '1_tablet_main_list.xsl'},
      
      'menu_section://main'     : {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_portrait.xsl'},
      'menu://'                 : {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'},
      'section://'              : {'pt': '1_tablet_section_list.xsl',               'ls': '1_tablet_section_list.xsl'},
      'noticia://'              : {'pt': '3_tablet_new_global.xsl',                 'ls': '3_tablet_new_global.xsl'},
      
      'ls_menu_section://main'  : {'pt': '2_tablet_noticias_index_landscape.xsl',   'ls': '2_tablet_noticias_index_landscape.xsl'},
      'ls_menu_section://'      : {'pt': '2_tablet_noticias_seccion_landscape.xsl', 'ls': '2_tablet_noticias_seccion_landscape.xsl'},
      'ls_section://'           : {'pt': '2_section_list.xsl',                      'ls': '2_section_list.xsl'},
      'ls_noticia://'           : {'pt': '3_tablet_new_landscape.xsl',              'ls': '3_tablet_new_landscape.xsl'},

      'clasificados://'         : {'pt': '5_tablet_clasificados.xsl',               'ls': '5_tablet_clasificados.xsl'},      
      'funebres://'             : {'pt': '6_tablet_funebres.xsl',                   'ls': '6_tablet_funebres.xsl'},
      'farmacia://'             : {'pt': '7_tablet_farmacias.xsl',                  'ls': '7_tablet_farmacias.xsl'},
      'cartelera://'            : {'pt': '8_tablet_cartelera.xsl',                  'ls': '8_tablet_cartelera.xsl'},
    },
    'extras': {
      'has_clasificados' : True,
      'has_funebres'     : True,
      'has_farmacia'     : True,
      'has_cartelera'    : True,
    },
  }
}