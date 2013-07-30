{% macro NotaAbierta(node, container_type) -%}
    {% if node.thumbnail or
          node.group or
          node.content == 'audio' or 
          node.content == 'audio/mpeg' or 
          node.content == 'video' %}
      
      <div class="media_link {{container_type}}">
        {% if node.content == 'audio' %}
        <a class="ico_audio" href="audio://{$Node/content[@type='audio'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        {% endif %}
        <xsl:if test="$Node/content[@type='audio']">
          
        </xsl:if>
        <xsl:if test="$Node/content[@type='audio/mpeg']">
          <a class="ico_audio" href="audio://{$Node/content[@type='audio/mpeg'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        <xsl:if test="$Node/group/content">
          <xsl:variable name="gallery">
            <xsl:for-each select="$Node/group/content">
              <xsl:value-of select="concat(@url, ';')"/>
            </xsl:for-each>
          </xsl:variable>
          <a href="galeria://{$gallery}" title="galeria" class="ico_galeria"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        <xsl:if test="not($Node/group/content) and not(not($Node/thumbnail))">
          <!-- xsl:variable name="tmp">
            <xsl:value-of select="file://"/>
          </xsl:variable -->
          <a href="galeria://file://{$Node/thumbnail/@url}" title="galeria" class="ico_plus"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        <xsl:if test="$Node/content[@type='video']">
          <a class="ico_video" href="video://{$Node/content[@type='video'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      
      </div>
    </xsl:if>
  </xsl:template>
{%- endmacro %}


{% macro NotaAbierta(node) -%}
  <div id="nota">
  {% if node.thumbnail %}
    <div class="main_img_container">
      <div class="imagen_principal" id="{{node.thumbnail.value.attrs.url}}" style="background-image:url({{node.thumbnail.value.attrs.url}}.i);">
        {{ cc.MediaLink(node, 'video_over_photo') }}
        <xsl:variable name="container_type">video_over_photo</xsl:variable>
        <xsl:call-template name="MediaLink">
          <xsl:with-param name="Node" select="$Node"/>
          <xsl:with-param name="container_type" select="$container_type"/>
        </xsl:call-template>

      </div>
    </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="container_type">no_photo</xsl:variable>
          <xsl:call-template name="MediaLink">
            <xsl:with-param name="Node" select="$Node"/>
            <xsl:with-param name="container_type" select="$container_type"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      
      <div class="contenido">
        <div id="titulo">
            <label class="date">
              <xsl:call-template name="FormatDate">
                <xsl:with-param name="DateTime" select="$Node/pubDate"/>
              </xsl:call-template>
            </label> | <label class="seccion">
              <xsl:call-template name="ReplaceInfoGral">
                <xsl:with-param name="seccion" select="$Node/category"/>
              </xsl:call-template>
            </label>
          <br />
          <h1><xsl:value-of disable-output-escaping="yes" select="$Node/title" /></h1>
        </div>
        <xsl:if test="$Node/news:subheader and $Node/news:subheader!=''">
          <div class="bajada" id="bajada">
            <xsl:value-of disable-output-escaping="yes" select="$Node/news:subheader" />
          </div>
        </xsl:if>
        <div id="informacion" style="display:block;">
          <xsl:value-of disable-output-escaping="yes" select="$Node/news:content" />
        </div>
      </div>
    </div>
  </xsl:template>
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
      {{ ImagenNoticiaDestacada(node.thumbnail.value.attrs.url, node.meta) }}
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

{% macro DateSectionLabel(node) -%}    
  <label class="date">{{node.pubDate|datetime}}</label>&nbsp;|&nbsp;
  <label class="seccion">{{ 'Información Gral' if node.category == 'Información General' else node.category }}</label>
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
            <div class="imagen_secundaria" id="{{node.thumbnail.value.attrs.url}}" style="background-image:url({{node.thumbnail.value.attrs.url}}.i) !important;">&nbsp;</div>
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
      {% if meta.has_gallery == 'True' or meta.has_gallery == 'true' %}
      <div class="ico_galeria">&nbsp;</div>
      {% endif %}
      {% if meta.has_video == 'True' or meta.has_video == 'true' %}
      <div class="ico_video">&nbsp;</div>
      {% endif %}
      {% if meta.has_audio == 'True' or meta.has_audio == 'true' %}
      <div class="ico_audio">&nbsp;</div>
      {% endif %}
    &nbsp;
    </div>    
{%- endmacro %}

{% macro ImagenNoticiaDestacada(url, meta) -%}
    <div class="imagen" id="{{url}}" style="background-image:url({{url}}.i);">
      <div class="media_link video_over_photo">
        {{ MediaAttach(meta) }}
      </div>
    </div>
{%- endmacro %}

{% macro DestacadaEnListadoPrincipal(node) -%}
    <div id="nota">
      <a href="{{node|noticia_link}}" title="principal">
        {% if node.thumbnail %}
          {{ ImagenNoticiaDestacada(node.thumbnail.value.attrs.url, node.meta) }}
        {% endif %}
        <div class="contenido">
          <div id="titulo">
            <label>{{node.pubDate|datetime}}</label> | <label class="seccion">{{node.category}}</label>
            <br />
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
          {{ ImagenNoticiaDestacada(node.thumbnail.value.attrs.url, node.meta) }}
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
          {{ ImagenNoticiaDestacada(node.thumbnail.value.attrs.url, node.meta) }}
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
          {{ ImagenNoticiaDestacada(node.thumbnail.value.attrs.url, node.meta) }}
        {% else %}
        <div class="info">
          <p>{{node.description|if_not_none}}</p>
        </div>
        {% endif %}
      </div>
    </a>
{%- endmacro %}
