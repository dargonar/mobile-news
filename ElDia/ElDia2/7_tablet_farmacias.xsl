<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:include href="functions.xsl" />
  <xsl:output method="html"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <link rel="stylesheet" href="css/layout_tablet.css" type="text/css" />
        <!-- meta name="viewport" content="width=960;user-scalable=no;" / -->
        <meta name="viewport" content="width=device-width; minimum-scale=0.5; maximum-scale=0.8; user-scalable=no;');" />
        <title>FARMACIAS</title>
      </head>
      <body>

        <div id="clasificados">
          <div class="columna big">
            <div class="encabezado">
              <div class="rubro">Farmacias de turno</div>
              <div class="clear"></div>
              <div class="titulo"></div>
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'day'"/>
                </xsl:call-template>
              </div>
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'month'"/>
                </xsl:call-template>
              </div>
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'year'"/>
                </xsl:call-template>
              </div>
              <div class="clear"></div>
            </div>

            <div class="aviso two_columns" id="farmacia_list">
              <xsl:value-of disable-output-escaping="yes" select="rss/channel/item[1]" />
            </div>
          </div>  
        </div>
        
        <script type="text/javascript">
          //alert(document.getElementById('farmacia_list').innerHTML);
          var texti = document.getElementById('farmacia_list').innerHTML.replace(/\r\n/g, "<br />");
          texti = texti.replace(/\n/g, "<br />");
          document.getElementById('farmacia_list').innerHTML = texti;
        </script>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>