{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body onload="update_imagen_nota_abierta()">
    
    <xsl:call-template name="NotaAbierta">
      <xsl:with-param name="Node" select="rss/channel/item[1]"/>
    </xsl:call-template>
    
    <xsl:if test="rss/channel/item[1]/news:related" >
      <xsl:variable name="Title">Noticias relacionadas</xsl:variable>
      <xsl:call-template name="TituloSeccionONotisRelac">
        <xsl:with-param name="Titulo" select="$Title"/>
      </xsl:call-template>
      <xsl:call-template name="ListadoNoticiasRelacionadas">
        <xsl:with-param name="Items" select="rss/channel/item[1]/news:related"/>
      </xsl:call-template>
    </xsl:if>
  </body>
</html>