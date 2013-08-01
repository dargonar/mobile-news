{% macro tablet_open_new_global(node) -%}
<div id="index" class="padded top_padded">
  <div class="nota_abierta">
    {{ DateSectionLabel(node, 'fecha') }}
    <h1>{{node.title}}</h1>
    {% if node.subheader %}
    <p class="subtitulo" id="bajada">{{node.subheader.value}}</p>
    {% endif %}
    <div class="separador">&nbsp;</div>
    
    <div class="fila">
      {% if node.thumbnail %}
        <div class="main_img_container">
          <div class="imagen" id="{{node.thumbnail.attrs.url}}" style="background-image:url({{node.thumbnail.attrs.url}}.i);">
            {{ MediaLink(node, 'video_over_photo')}}
          </div>
        </div>
      {% endif %}
      <div id="informacion" class="contenido">
        {{node|content('html')}}
      </div>
    </div>
  </div>
</div>
{%- endmacro %}

{% macro NoticiaRelacionada(item) -%}
    <li>
      <a href="{{item|related_link}}" title="">
        <div class="titular {{'full_width' if item.attrs.thumbnail == '' else ''}}">
          <div class="header">
            <label class="date">{{item.attrs.pubDate|datetime}}</label>
            {% if item.attrs.category != '' %}
              &nbsp;|&nbsp;
              <label class="seccion">{{ 'Información Gral' if item.attrs.category == 'Información General' else item.attrs.category }}
              </label>
            {% endif %}
          </div>
          <br />
          <label class="titulo">{{item.value}}</label>
        </div>
        
        {% if item.attrs.thumbnail != '' %}
          <div class="foto img_container">
            <div class="imagen_secundaria" id="{{item.attrs.thumbnail}}" style="background-image:url({{item.attrs.thumbnail}}.i) !important;"></div>
            <div class="img_loader">&nbsp;</div>
          </div>
        {% endif %}        
      </a>
      <div class="separador">&nbsp;</div>
    </li>
{%- endmacro %}

{% macro ListadoNoticiasRelacionadas(items) -%}
    <div id="listado" style="display:block;">
      <ul class="main_list">
        {% for item in items %}
        {{ NoticiaRelacionada(item) }}
        {% endfor %}
      </ul>
    </div>
{%- endmacro %}

{% macro TituloSeccionONotisRelac(title) -%}
    <div id="titulo_seccion">
      <label class="lbl_titulo_seccion">{{title}}</label>
    </div>
{%- endmacro %}

{% macro MediaLink(node, container_type) -%}
  {% if node|has_content('any_media') or node.group or node.thumbnail %}
    <div class="media_link {{container_type}}">
    {% if node|has_content('audio') %}
      <a class="ico_audio" href="audio://{{node|content('audio')}}" title="">&nbsp;</a>
    {% endif %}
    {% if node|has_content('audio/mpeg') %}    
      <a class="ico_audio" href="audio://{{node|content('audio/mpeg')}}" title="">&nbsp;</a>
    {% endif %}
    {% if node.group %}
      <a href="galeria://{{node|gallery}}" title="galeria" class="ico_galeria">&nbsp;</a>
    {% endif %}
    {% if not node.group and node.thumbnail %}
      <a href="galeria://file://{{node.thumbnail.attrs.url}}" title="galeria" class="ico_plus">&nbsp;</a>
    {% endif %}
    {% if node|has_content('video') %}
      <a class="ico_video" href="video://{{node|content('video')}}" title="">&nbsp;</a>
    {% endif %}
    &nbsp;
    </div>
  {% endif %}
{%- endmacro %}

{% macro NotaAbierta(node) -%}
  <div id="nota">
    {% if node.thumbnail %}
      <div class="main_img_container">
      {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
      </div>
    {% else %}
      {{ MediaLink(node, 'no_photo') }}
    {% endif %}
    
    <div class="contenido">
      <div id="titulo">
      {{ DateSectionLabel(node) }}
      <br />
      <h1>{{node.title}}</h1>
      </div>
      {% if node.subheader %}
        <div class="bajada" id="bajada">
          {{node.subheader.value}}
        </div>
      {% endif %}
      <div id="informacion" style="display:block;">
        {{node|content('html')|if_not_none}}
      </div>
    </div>
  </div>
{%- endmacro %}


{% macro tablet_news_list_landscape(nodes) -%}
  {% for node in nodes %}
  {{ tablet_news_list_landscape_item(node) }}
  {% endfor %}
{%- endmacro %}

{% macro tablet_news_list_landscape_item(node) -%}
  <li>  
    <a href="{{node|noticia_link}}" title="principal">
      {% if node.thumbnail %}
      {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
      {% endif %}
      <div class="info"><p>{{node.title}}</p></div>
      {% if not node.thumbnail %}
      <div class="subheader">
        <p>{{node.description|if_not_none}}</p>
      </div>
      {% endif %}
    </a>
  </li>
{%- endmacro %}

{% macro Head(layout) -%}
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" type="text/css" href="css/{{layout}}.css" />
    <script type="text/javascript" src="js/functions.js"></script>
  </head>
{%- endmacro %}

{% macro UpdatedAt(layout) -%}
  <div id="updated_msg" class="updated hidden">Actualizado hace 1 segundo</div>
{%- endmacro %}

{% macro DateSectionLabel(node, class='date') -%}    
  <label class="{{class}}">{{node.pubDate|datetime}}</label>
  {% if node.category %}
  &nbsp;|&nbsp;<label class="seccion">{{ 'Información Gral' if node.category == 'Información 
  General' else node.category }}
  {% endif %}
  </label>

{%- endmacro %}

{% macro NoticiaEnListado(node) -%}    
    <li>
        <a href="{{node|noticia_link}}" title="">
        <div class="titular {{'' if node.thumbnail else 'full_width'}}">
          <div class="header">
            {{ DateSectionLabel(node) }}
          </div>
          <br />
          <label class="titulo">{{node.title}}</label>
        </div>
        
        {% if node.thumbnail %}
          <div class="foto img_container">
            {% if node.meta %}
              {{ MediaAttach(node.meta) }}
            {% endif %}          
            <div class="imagen_secundaria" id="{{node.thumbnail.attrs.url}}" style="background-image:url({{node.thumbnail.attrs.url}}.i) !important;">&nbsp;</div>
            <div class="img_loader">&nbsp;</div>
          </div>
        {% else %}
            {% if node.meta %}
            <div class="right_ico_container">
              {{ MediaAttach(node.meta) }}
            </div>
            {% endif %}          
        {% endif %}
        </a>
        <div class="separador">&nbsp;</div>
    </li>
{%- endmacro %}

{% macro MediaAttach(meta) -%}
    <div class="ico_container">
      {% if meta|meta_has('gallery') %}
      <div class="ico_galeria">&nbsp;</div>
      {% endif %}
      {% if meta|meta_has('video') %}
      <div class="ico_video">&nbsp;</div>
      {% endif %}
      {% if meta|meta_has('audio') %}
      <div class="ico_audio">&nbsp;</div>
      {% endif %}
    &nbsp;
    </div>    
{%- endmacro %}

{% macro ImagenNoticiaDestacada(url, meta) -%}
    <div class="imagen_principal" id="{{url}}" style="background-image:url({{url}}.i);">
      <div class="media_link video_over_photo">
        {{ MediaAttach(meta) }}
      </div>
    </div>
{%- endmacro %}

{% macro DestacadaEnListadoPrincipal(node) -%}
    <div id="nota">
      <a href="{{node|noticia_link}}" title="principal">
        {% if node.thumbnail %}
          {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
        {% endif %}
        <div class="contenido">
          <div id="titulo">
            {% if node.pubDate %}
            <label>{{node.pubDate|datetime}}</label> | <label class="seccion">{{node.category}}</label>
            <br />
            {% endif %}
            <h1>{{node.title}}</h1>
          </div>
        </div>
      </a>
      <div class="separador">&nbsp;</div>
    </div>    
{%- endmacro %}

{% macro ListadoNoticiasEnListado(nodes) -%}

  <div id="listado" style="display:block;">
    <ul class="main_list">
      {% for node in nodes %}
        {{ NoticiaEnListado(node) }}
      {% endfor %}
    </ul>
  </div>
    
{%- endmacro %}

{% macro tablet_index_portrait_main(node) -%}
    <a href="{{node|noticia_link}}" title="principal">
      <div class="nota_principal">
        <div class="info">
          <div class="encabezado">
              {{ DateSectionLabel(node) }}
              <h1>{{node.title}}</h1>
              <p class="subtitulo">{{node.description|if_not_none}}</p>
          </div>
        </div>
        {% if node.thumbnail %}
          {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
        {% endif %}
      </div>
    </a>
    <div class="separador">&nbsp;</div>
{%- endmacro %}

{% macro tablet_index_portrait_secondary(nodes) -%}
    {% for node in nodes %}
      {{ tablet_index_portrait_secondary_item(node, 'last' if loop.last else '') }}
    {% endfor %}
    <div class="separador">&nbsp;</div>
{%- endmacro %}

{% macro tablet_index_portrait_secondary_item(node, class) -%}
    <a href="{{node|noticia_link}}" title="principal">
      <div class="nota_secundaria {{class}}">
        {{ DateSectionLabel(node) }}
        <h1>{{node.title}}</h1>
        {% if node.thumbnail %}
          {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
        {% else %}
        <div class="info">
          <p>{{node.description|if_not_none}}</p>
        </div>
        {% endif %}
      </div>
    </a>
{%- endmacro %}

{% macro tablet_index_portrait_terciary(nodes) -%}
    {% for node in nodes %}
      {{ tablet_index_portrait_terciary_item(node, 'last' if loop.index % 3 == 0 else '') }}
      {% if loop.index % 3 == 0 %}
      <div class="separador">&nbsp;</div>
      {% endif %}
    {% endfor %}
{%- endmacro %}

{% macro tablet_index_portrait_terciary_item(node, class) -%}
    <a href="{{node|noticia_link}}" title="principal">
      <div class="nota_terciaria {{class}}">
        {{ DateSectionLabel(node) }}
        <h2>{{node.title}}</h2>
        {% if node.thumbnail %}
          {{ ImagenNoticiaDestacada(node.thumbnail.attrs.url, node.meta) }}
        {% else %}
        <div class="info">
          <p>{{node.description|if_not_none}}</p>
        </div>
        {% endif %}
      </div>
    </a>
{%- endmacro %}
