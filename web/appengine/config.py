# -*- coding: utf-8 -*-
config = {}

config['webapp2'] = {
    'apps_installed': [
        'apps.backend',
        'apps.frontend',
        'apps.mvp_1',
        'apps.ws'
    ],
}

config['webapp2_extras.sessions'] = {
  'secret_key'  : '2 7 FOXTROT 7 YANKEE 6 1 6 VICTOR HOTEL 1 delta QUEBEC 0 3',
  'cookie_name' : 'mobipaper',
}

config['webapp2_extras.jinja2'] = {
  'template_path' :  'templates',
  'compiled_path' :  'templates_compiled',
  'force_compiled':  False,

  'environment_args': {
    'autoescape': False,
  }
}

config['mobipaper'] = {
}