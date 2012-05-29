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