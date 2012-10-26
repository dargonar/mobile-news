<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:include href="url-encode.xsl" />
  <!--  Con estas variables podemos convertir un string en upper case o lower case. 
        -) translate($variable, $smallcase, $uppercase)
        No se utilizan
  -->  
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  
  <!-- Formateo de fecha en HH:mm -->
  <xsl:template name="FormatDate">
    <xsl:param name="DateTime" />
    <xsl:variable name="mo">
      <xsl:value-of select="substring($DateTime,1,3)" />
    </xsl:variable>
    <xsl:variable name="day-temp">
      <xsl:value-of select="substring-after($DateTime,', ')" />
    </xsl:variable>
    <xsl:variable name="day">
      <xsl:value-of select="substring-before($day-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="month-year-temp">
      <xsl:value-of select="substring-after($day-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="month">
      <xsl:value-of select="substring-before($month-year-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="year-time-temp">
      <xsl:value-of select="substring-after($month-year-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="year">
      <xsl:value-of select="substring-before($year-time-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="time">
      <xsl:value-of select="substring-after($year-time-temp,' ')" />
    </xsl:variable>
    <xsl:variable name="hh">
      <xsl:value-of select="substring-before($time,':')" />
    </xsl:variable>
    <xsl:variable name="mm_ss">
      <xsl:value-of select="substring-after($time,':')" />
    </xsl:variable>
    <xsl:variable name="mm">
      <xsl:value-of select="substring-before($mm_ss,':')" />
    </xsl:variable>
    <xsl:variable name="ss_gmt">
      <xsl:value-of select="substring-after($mm_ss,':')" />
    </xsl:variable>
    <xsl:variable name="ss">
      <xsl:value-of select="substring-before($ss_gmt,' ')" />
    </xsl:variable>
    <xsl:value-of select="$hh"/>
    <xsl:value-of select="':'"/>
    <xsl:value-of select="$mm"/>
  </xsl:template>
  
  <!-- Es el template de la noticia destacada en listado principal de noticias.
        Recibe al nodo "item"(Node) como parametro. -->
  <xsl:template name="DestacadaEnListadoPrincipal">
    <xsl:param name="Node" />
    <div id="nota">
      <xsl:call-template name="url-encode">
        <xsl:with-param name="str" select="{$Node/link}"/>
      </xsl:call-template>
      <a href="noticia://{$Node/guid}?url={$link}&title={$Node/title}&header={$Node/description}" title="principal">
        <xsl:if test="not(not($Node/media:thumbnail))" >
          <xsl:call-template name="ImagenNoticiaDestacada">
            <xsl:with-param name="ImageUrl" select="$Node/media:thumbnail/@url"/>
            <xsl:with-param name="MetaTag" select="$Node/news:meta"/>
          </xsl:call-template>
        </xsl:if>
        <div class="contenido">
          <div id="titulo">
            <label>
              <xsl:call-template name="FormatDate">
                <xsl:with-param name="DateTime" select="$Node/pubDate"/>
              </xsl:call-template>
            </label> | <label class="seccion"><xsl:value-of select="$Node/category" /></label>
            <!--div class="ico_video" href="#" style="display:block;"></div --><br />
            <h1><xsl:value-of select="$Node/title" /></h1>
          </div>
        </div>
      </a>
      <div class="separador"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
    </div>
  </xsl:template>
  
  <!-- Template de la imagen grande de la noticia destacada en el listado principal (DestacadaEnListadoPrincipal). -->
  <xsl:template name="ImagenNoticiaDestacada">
    <xsl:param name="ImageUrl" />
    <xsl:param name="MetaTag" />
    <div class="main_img_container">
      <!-- img src="{$ImageUrl}" / -->
      <div class="imagen_principal" id="{$ImageUrl}" style="background-image:url(i_{$ImageUrl});"></div>
      <div class="media_link video_over_photo"> <!-- plus -->
        <xsl:call-template name="MediaAttach">
          <xsl:with-param name="MetaTag" select="$MetaTag"/>
        </xsl:call-template>
      </div>
    </div>
  </xsl:template>
  
  <!-- Template del listado de noticias uniforme. Para listado principal o de seccion. -->
  <xsl:template name="ListadoNoticiasEnListado">
    <xsl:param name="Nodes" />
    <div id="listado" style="display:block;">
      <ul class="main_list">
        <xsl:for-each select="$Nodes">
          <xsl:call-template name="NoticiaEnListado">
            <xsl:with-param name="Node" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  
  <!-- Template de la noticia en listado de noticias uniforme (ListadoNoticiasEnListado). Para listado principal o de seccion. -->  
  <xsl:template name="NoticiaEnListado">
    <xsl:param name="Node" />
    
    <xsl:variable name="has_image" select="not(not($Node/media:thumbnail))"></xsl:variable>
    <xsl:variable name="full_width" >
      <xsl:if test="not($has_image)">
        <xsl:text>full_width</xsl:text>
      </xsl:if>
    </xsl:variable>
    
    <li>
      <a href="noticia://{$Node/guid}?url={$Node/link}&title={$Node/title}&header={$Node/description}" title="">
        <div class="titular {$full_width}">
          <label>
            <xsl:call-template name="FormatDate">
              <xsl:with-param name="DateTime" select="$Node/pubDate"/>
            </xsl:call-template>
          </label><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>|<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text><label class="seccion"><xsl:value-of select="$Node/category" /></label><br />
          <label class="titulo"><xsl:value-of select="$Node/title" /></label>
        </div>
        
        <xsl:if test="not(not($has_image))">
          <div class="foto img_container">
            <xsl:if test="not(not($Node/news:meta))">
              <xsl:call-template name="MediaAttach">
                <xsl:with-param name="MetaTag" select="$Node/news:meta"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(not($Node/media:thumbnail))">
              <div class="imagen_secundaria" id="{$Node/media:thumbnail/@url}" style="background-image:url(i_{$Node/media:thumbnail/@url}) !important;"></div>
              <div class="img_loader"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
              <!-- img src="{$Node/media:thumbnail/@url}" / -->
            </xsl:if>
            <xsl:if test="not($Node/media:thumbnail)">
              <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
            </xsl:if>
          </div>
        </xsl:if>
        <xsl:if test="not($has_image)">
          <xsl:if test="not(not($Node/news:meta))">
            <div class="right_ico_container">
              <xsl:call-template name="MediaAttach">
                <xsl:with-param name="MetaTag" select="$Node/news:meta"/>
              </xsl:call-template>
            </div>
          </xsl:if>
        </xsl:if>
      </a>
      <div class="separador"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
    </li>
  </xsl:template>
  
  <!-- Template para indicar que elementos multimedia que tiene la noticia. -->
  <xsl:template name="MediaAttach">
    <!-- <news:meta has_gallery="true" has_video="false" has_audio="false" /> -->
    <xsl:param name="MetaTag" />
    <!--xsl:param name="GuidTag" /-->
    <div class="ico_container">
      <xsl:if test="$MetaTag/@has_gallery='true' or $MetaTag/@has_gallery='True'">
        <div class="ico_galeria"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
      </xsl:if>
      <xsl:if test="$MetaTag/@has_video='true' or $MetaTag/@has_video='True'">
        <div class="ico_video"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
      </xsl:if>
      <xsl:if test="$MetaTag/@has_audio='true' or $MetaTag/@has_audio='True'">
        <div class="ico_audio"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
      </xsl:if>
      <!-- xsl:if test="$MetaTag/@has_audio='false' and $MetaTag/@has_video='false' and $MetaTag/@has_gallery='false'">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </xsl:if -->
      <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
    </div>
  </xsl:template>

  <!-- Template de la nota abierta con o sin imagen.-->
  <xsl:template name="NotaAbierta">
    <xsl:param name="Node" />
    <div id="nota">
      <xsl:choose>
        <xsl:when test="not(not($Node/media:thumbnail))">
          <div class="main_img_container">
            <img src="{$Node/media:thumbnail/@url}" />
            <xsl:variable name="container_type">video_over_photo</xsl:variable>
            <xsl:call-template name="MediaLink">
              <xsl:with-param name="Node" select="$Node"/>
              <xsl:with-param name="container_type" select="$container_type"/>
            </xsl:call-template>
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
          <label>
            <xsl:call-template name="FormatDate">
              <xsl:with-param name="DateTime" select="$Node/pubDate"/>
            </xsl:call-template>
          </label> | <label class="seccion"><xsl:value-of select="$Node/category" /></label>
          <br />
          <h1><xsl:value-of select="$Node/title" /></h1>
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
  
  <!-- Template para permitir acceder a elementos multimedia de la noticia. -->
  <xsl:template name="MediaLink">
    <!-- <news:meta has_gallery="true" has_video="false" has_audio="false" /> -->
    <xsl:param name="Node" />
    <xsl:param name="container_type" />
    <xsl:if test="$Node/media:content[@type='audio'] or $Node/media:content[@type='audio/mpeg'] or $Node/media:group/media:content or $Node/media:content[@type='video']" >
      <div class="media_link {$container_type}">
        
        <xsl:if test="$Node/media:content[@type='audio']">
          <a class="ico_audio" href="audio://{$Node/media:content[@type='audio'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        <xsl:if test="$Node/media:content[@type='audio/mpeg']">
          <a class="ico_audio" href="audio://{$Node/media:content[@type='audio/mpeg'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        <xsl:if test="$Node/media:group/media:content">
          <xsl:variable name="gallery">
            <xsl:for-each select="$Node/media:group/media:content">
              <xsl:value-of select="concat(@url, ';')"/>
            </xsl:for-each>
          </xsl:variable>
          <a href="galeria://{$gallery}" title="galeria" class="ico_galeria"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        <!--xsl:if test="$Node/media:thumbnail">
          <a href="galeria://{$Node/media:thumbnail/@url};{$Node/media:thumbnail/@url};{$Node/media:thumbnail/@url}" title="galeria" class="ico_galeria"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if-->
        
        <xsl:if test="$Node/media:content[@type='video']">
          <a class="ico_video" href="video://{$Node/media:content[@type='video'][1]/@url}" title=""><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></a>
        </xsl:if>
        
        
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- Template generador del link de las imegenes de la galeria. -->
  <!--xsl:template name="GalleryTemplate">
    <xsl:param name="media_group" />
    <xsl:for-each select="$media_group/media:content">
      <xsl:value-of select="concat( substring('; ','{@url}'),.)"/>
    </xsl:for-each>
  </xsl:template-->
  
  <!-- Template que arma el listado de noticias relacionadas. -->
  <xsl:template name="ListadoNoticiasRelacionadas">
    <xsl:param name="Items" />
    <div id="listado" style="display:block;">
      <ul class="main_list">
        <xsl:for-each select="$Items">
          <xsl:call-template name="NoticiaRelacionada">
            <xsl:with-param name="Item" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  
  <!-- Template de la noticia en listado de noticias relacionadas (ListadoNoticiasRelacionadas). -->  
  <xsl:template name="NoticiaRelacionada">
    <xsl:param name="Item" />
    
    <xsl:variable name="has_image" select="$Item/@thumbnail!=''"></xsl:variable>
    <xsl:variable name="full_width" >
      <xsl:if test="not($has_image)">
        <xsl:text>full_width</xsl:text>
      </xsl:if>
    </xsl:variable>
    
    <li>
      <a href="noticia://{$Item/@guid}?url={$Item/@url}&title={$Item/.}&header=" title="">
        <div class="titular {$full_width}">
          <label>
            <xsl:call-template name="FormatDate">
              <xsl:with-param name="DateTime" select="$Item/@pubDate"/>
            </xsl:call-template>
          </label> 
          <xsl:if test="$Item/@lead!=''">
            <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>|<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
            <label class="seccion"><xsl:value-of select="$Item/@lead" /></label> 
          </xsl:if>
          <br />
          <label class="titulo"><xsl:value-of select="$Item/." /></label>
        </div>
        
        <xsl:if test="not(not($has_image))">
          <div class="foto img_container">
            <xsl:call-template name="MediaAttach">
              <xsl:with-param name="MetaTag" select="$Item/news:meta"/>
            </xsl:call-template>
            <xsl:if test="not(not($Item/@thumbnail))">
              <xsl:if test="$Item/@thumbnail!=''">
                <div class="imagen_secundaria" id="{$Item/@thumbnail}" style="background-image:url(i_{$Item/@thumbnail}) !important;"></div>
                <div class="img_loader"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
              </xsl:if>
            </xsl:if>
            <!--xsl:if test="not($Item/@thumbnail) or $Item/@thumbnail=''">
              <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
            </xsl:if-->
          </div>
        </xsl:if>
        
        <xsl:if test="not($has_image)">
          <xsl:if test="not(not($Item/news:meta))">
            <div class="right_ico_container">
              <xsl:call-template name="MediaAttach">
                <xsl:with-param name="MetaTag" select="$Item/news:meta"/>
              </xsl:call-template>
            </div>
          </xsl:if>
        </xsl:if>
      </a>
      <div class="separador"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
    </li>
  </xsl:template>
  
  <!-- Template para el titulo de seccion o el header de las noticias relacionadas. -->
  <xsl:template name="TituloSeccionONotisRelac">
    <xsl:param name="Titulo" />
    <div id="titulo_seccion"><label class="lbl_titulo_seccion"><xsl:value-of select="$Titulo" /></label></div>
  </xsl:template>
  
</xsl:stylesheet>
