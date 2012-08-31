<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:output method="html"/>

  <xsl:template match="/">
    <html>
    <head>
      <META http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>XXX</title>
        <link rel="stylesheet" type="text/css" href="http://localhost:8090/css/2.css" />
      </head>
      <body bgcolor="#ffffff" >
        <section class="entries">
          <xsl:for-each select="rss/channel/item">
            <article class="entry">
              <a href="{guid}" class="info floatFix" rel="external" alt="" title="">
                <xsl:apply-templates select="media:thumbnail"/> <!-- xsl:value-of select="media:thumbnail/@url"/-->
                <h1 class="entry_title" target="_blank" rel="external" ><xsl:value-of select="title"/></h1>
                <div class="subheader entry_content with_image">
                  <xsl:value-of select="news:subheader"/>
                </div>
              </a>
            </article>
          </xsl:for-each>  
        </section>
      </body>
    </html>
  </xsl:template>
    
  <xsl:template match="media:thumbnail">      
    <div class="contenedorImg">
      <img style="width:117px" src="{@url}" class="lazyLoad"/>
    </div>
  </xsl:template>


</xsl:stylesheet>