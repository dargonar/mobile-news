# -*- coding: utf-8 -*-
import logging
import urllib
import urlparse

from HTMLParser import HTMLParser
from dateutil.parser import parser

from re import *

from google.appengine.ext import db

from webapp2 import abort, cached_property, RequestHandler, Response, HTTPException, uri_for as url_for, get_app
from webapp2_extras import jinja2, sessions, json

_slugify_strip_re = compile(r'[^\w\s-]')
_slugify_hyphenate_re = compile(r'[-\s]+')
def do_slugify(value):
  """
  Normalizes string, converts to lowercase, removes non-alpha characters,
  and converts spaces to hyphens.
  
  From Django's "django/template/defaultfilters.py".
  """
  import unicodedata
  
  if not isinstance(value, unicode):
      value = unicode(value)
  value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore')
  value = unicode(_slugify_strip_re.sub('', value).strip().lower())
  return _slugify_hyphenate_re.sub('-', value)

def empty(value):
  return value is None or value == ''

def related_link(item):
  return 'noticia://%s?url=%s&title=%sheader=' % (item.attrs.guid, url_fix(item.attrs.url), url_fix(item.value))

def meta_has(meta, media_type):
  if meta is None or meta.attrs is None or not hasattr(meta.attrs, 'has_' + media_type):
    return False

  if getattr(meta.attrs, 'has_' + media_type).lower() != 'true':
    return False  
  
  return True

def gallery(node):
  if node is None or node.group is None:
    return ''
  urls = []
  for c in node.group.content:
    urls.append(c.attrs.url.strip())
  return ';'.join(urls)

def has_content(node, content_type='any_media'):
  if node is None or node.content is None:
    return False
  if content_type == 'any_media':
    content_to_check = ['audio', 'audio/mpeg', 'video']
  else:
    content_to_check = [content_type]
  ret = False

  if type(node.content) != type([]):
    contents = [node.content]
  else:
    contents = node.content

  for content in contents:
    if content.attrs.type in content_to_check:
      ret = True
      break
  return ret

def get_content(node, content_type):

  if node is None or node.content is None:
    return ''

  if type(node.content) != type([]):
    contents = [node.content]
  else:
    contents = node.content

  res = ''
  for content in contents:
    if content.attrs.type == content_type:
      if content_type == 'html':
        res = content.value
      else:
        res = content.attrs.url
      break
  return res

def build_list(value):
  if type(value) == type([]):
    return value

  return [value]

def format_datetime(value, part='%H:%m'):
    if value is None:
      return ''
    p = parser()
    return p.parse(value, default=None, ignoretz=True).strftime(part)

def if_not_none(value):
  if not value:
    return ''

  return value

def noticia_link(node):
  return 'noticia://%s?url=%s&title=%s&header=%s' % (node.guid.value, url_fix(node.link), url_fix(node.title), url_fix(node.description))

def url_fix(s, charset='utf-8'):
    """Sometimes you get an URL by a user that just isn't a real
    URL because it contains unsafe characters like ' ' and so on.  This
    function can fix some of the problems in a similar way browsers
    handle data entered by the user:

    >>> url_fix(u'http://de.wikipedia.org/wiki/Elf (Begriffsklärung)')
    'http://de.wikipedia.org/wiki/Elf%20%28Begriffskl%C3%A4rung%29'

    :param charset: The target charset for the URL if the url was
                    given as unicode string.
    """

    if s is None:
      return ''

    h = HTMLParser()
    s = h.unescape(s)
    if isinstance(s, unicode):
        s = s.encode(charset, 'ignore')
    scheme, netloc, path, qs, anchor = urlparse.urlsplit(s)
    path = urllib.quote(path, '/%')
    qs = urllib.quote_plus(qs, ':&=')
    return urlparse.urlunsplit((scheme, netloc, path, qs, anchor))
  
def get_or_404(key):
  try:
      obj = db.get(key)
      if obj:
          return obj
  except db.BadKeyError, e:
      # Falling through to raise the NotFound.
      pass

  abort(404)

class FlashBuildMixin(object):
  def set_error(self, msg):
    self.session.add_flash(self.build_error(msg))
    
  def set_ok(self, msg):
    self.session.add_flash(self.build_ok(msg))
    
  def set_info(self, msg):
    self.session.add_flash(self.build_info(msg))
    
  def set_warning(self, msg):
    self.session.add_flash(self.build_warning(msg))
  
  def build_error(self, msg):
    return { 'type':'error', 'message':msg }
    
  def build_ok(self, msg):
    return { 'type':'success', 'message':msg }
  
  def build_info(self, msg):
    return { 'type':'info', 'message':msg }
    
  def build_warning(self, msg):
    return { 'type':'warning', 'message':msg }
    
class Jinja2Mixin(object):
  
  @cached_property
  def jinja2(self):
    j2 = jinja2.get_jinja2(app=self.app)
      
    self.setup_jinja_enviroment(j2.environment)
      
    # Returns a Jinja2 renderer cached in the app registry.
    return j2

  def setup_jinja_enviroment(self, env):
    env.globals['url_for'] = self.uri_for
    
    if hasattr(self.session, 'get_flashes'):
      flashes = self.session.get_flashes()
      env.globals['flash'] = flashes[0][0] if len(flashes) and len(flashes[0]) else None
    
    env.globals['session']     = self.session
    
    env.filters['urlencode']   = url_fix
    env.filters['datetime']    = format_datetime
    env.filters['noticia_link'] = noticia_link
    env.filters['if_not_none'] = if_not_none
    env.filters['has_content']   = has_content
    env.filters['content']   = get_content
    env.filters['gallery']   = gallery
    env.filters['meta_has']   = meta_has
    env.filters['related_link']   = related_link
    env.filters['build_list']   = build_list
    env.filters['is_empty']   = empty
    

          
  def render_response(self, _template, **context):
    # Renders a template and writes the result to the response.
    rv = self.jinja2.render_template(_template, **context)
    self.response.write(rv)
  
  def render_template(self, _template, **context):
    # Renders a template and writes the result to the response.
    rv = self.jinja2.render_template(_template, **context)
    return rv
      
class MyBaseHandler(RequestHandler, Jinja2Mixin, FlashBuildMixin):
  def dispatch(self):
    # Get a session store for this request.
    self.session_store = sessions.get_store(request=self.request)

    try:
      # Dispatch the request.
      RequestHandler.dispatch(self)
    finally:
      # Save all sessions.
      self.session_store.save_sessions(self.response)

  @cached_property
  def session(self):
    # Returns a session using the default cookie key.
    return self.session_store.get_session()
  
  def render_json_response(self, *args, **kwargs):
    self.response.content_type = 'application/json'
    self.response.write(json.encode(*args, **kwargs))
    
  # def handle_exception(self, exception=None, debug=False):
  #   logging.exception(exception)
    
  #   text = 'Se ha producido un error en el servidor,<br/>intenta volver al inicio'
  #   code = 500
    
  #   if isinstance(exception,HTTPException):
  #     if exception.code == 404:
  #       text = u'La página solicitada no ha sido encontrada,<br/>intenta volver al inicio'
      
  #     code = exception.code
    
  #   self.render_response('error.html', code=code, text=text )
  #   self.response.status = str(code)+' '

  @cached_property
  def config(self):
    return get_app().config
    
class FrontendMixin(object):
  def do_fullversion(self):
    self.session['fullversion']                  = True
  def dont_fullversion(self):
    self.session['fullversion']                  = False
    
class FrontendHandler(MyBaseHandler, FrontendMixin):
  pass

