# -*- coding: utf-8 -*-
config = {}

config['webapp2'] = {
    'apps_installed': [
        'apps.backend',
        'apps.frontend',
        'apps.mvp_1',
    ],
}

config['webapp2_extras.sessions'] = {
  'secret_key'  : 'deremate punto com',
  'cookie_name' : 'mobipaper',
}

config['webapp2_extras.jinja2'] = {
  'template_path':  'templates',
  'compiled_path':  None, #'templates_compiled',
  'force_compiled': False,

  'environment_args': {
    'autoescape': False,
  }
}

config['mobipaper'] = {
}

import mimetypes 
#add webfonts mimetypes
mimetypes.add_type("application/vnd.ms-fontobject", ".eot")
mimetypes.add_type("application/x-font-ttf", ".ttc")
mimetypes.add_type("application/x-font-ttf", ".ttf")
mimetypes.add_type("font/opentype", ".otf")
mimetypes.add_type("application/x-font-woff", ".woff")
mimetypes.add_type("text/vnd.sun.j2me.app-descriptor", ".jad")
mimetypes.add_type("application/vnd.rim.cod", ".cod")