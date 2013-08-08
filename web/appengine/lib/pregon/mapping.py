# -*- coding: utf-8 -*-
def get_mapping():
  return {
  'pregon' : {
    'httpurl' : {
      'section://main'  : 'X: pregon.rss_index' ,
      'noticia://'      : 'X: pregon.rss_noticia',
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
      'section://main'  : {'pt': '2_tablet_noticias_index_portrait.xsl',    'ls': '2_tablet_noticias_index_landscape.xsl'},
      'noticia://'      : {'pt': '3_new.xsl',                               'ls': '3_new.xsl'},
      'section://'      : {'pt': '2_tablet_noticias_seccion_portrait.xsl',  'ls': '2_tablet_noticias_seccion_landscape.xsl'},
      'clasificados://' : {'pt': '5_clasificados.xsl',                      'ls': '5_clasificados.xsl'},
      'menu://'         : {'pt': '4_tablet_menu_secciones.xsl',             'ls': '4_tablet_menu_secciones.xsl'},
      'funebres://'     : {'pt': '6_funebres.xsl',                          'ls': '6_funebres.xsl'},
      'farmacia://'     : {'pt': '7_farmacias.xsl',                         'ls': '7_farmacias.xsl'},
      'cartelera://'    : {'pt': '8_cartelera.xsl',                         'ls': '8_cartelera.xsl'},
    },
    'extras': {
      'has_clasificados' : False,
      'has_funebres'     : False,
      'has_farmacia'     : False,
      'has_cartelera'    : False,
    }, 
  }
}