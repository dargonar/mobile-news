<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
  <!-- Copy everything -->
  <xsl:template match="@*|node()|text()|processing-instruction()">
     <xsl:copy>
       <xsl:apply-templates select="@*|node()|text()|processing-instruction()"/>
     </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <html>
      <head>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>XXX</title>
        <!-- link rel="stylesheet" type="text/css" href="http://localhost:8090/css/2.css" / -->
      </head>
      <body bgcolor="#ffffff" >
        <xsl:apply-templates select="rss/channel/item" />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="rss/channel/item">  
    <section class="entry_open">
      <div>
        <section class="header">
          <h2><xsl:value-of select="news:lead"/></h2>
          <h1><xsl:value-of select="title"/></h1>
          <p class="subheader">
            <xsl:value-of select="news:subheader"/>
          </p>
          <span class="entry_meta"><xsl:value-of select="pubDate"/></span> <!--29.05.2012 | 18:02-->
        </section>
        
        <div class="separator"></div>
        
        <xsl:apply-templates select="media:thumbnail"/>
        
        <section class="cuerpo">
          <xsl:value-of disable-output-escaping="yes" select="news:content"/>
        </section>
        
        <xsl:if test="not(not(news:related))" >
          <div class="separator"></div>
          <section class="relacionadas">
            <div class="titulo">
              <span class="cool_font">Notas relacionadas</span>
            </div>        
            <xsl:for-each select="news:related">
              <div class="relacionada">
                <section class="entries">
                  <article class="entry">
                    <a href="_HREF_" class="info floatFix" rel="external">
                      <h1 class="entry_title" target="_blank" rel="external" ><xsl:value-of select="@lead"/></h1>
                      <div class="subheader entry_content ">
                        <span class="entry_meta">
                          <!--xsl:value-of select="@pubDate"/-->
                          <xsl:call-template name="FormatDate">
                            <xsl:with-param name="DateTime" select="@pubDate"/>
                          </xsl:call-template>
                        </span><xsl:text> </xsl:text>|<xsl:text> </xsl:text><xsl:value-of select="."/>
                      </div>
                    </a>
                  </article>
                </section>
              </div>
            </xsl:for-each>  
          </section>
        </xsl:if>
      </div>
    </section>
  </xsl:template>
  
  
  
  <xsl:template match="media:thumbnail">  
    <section class="imagen">
      <figure><img src="{@url}" /></figure>
      <div class="separator"></div>
    </section>
  </xsl:template>
  
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
    <!--xsl:value-of select="$year"/>
    <xsl:value-of select="'-'"/>
    <xsl:choose>
      <xsl:when test="$mo = 'Jan'">01</xsl:when>
      <xsl:when test="$mo = 'Feb'">02</xsl:when>
      <xsl:when test="$mo = 'Mar'">03</xsl:when>
      <xsl:when test="$mo = 'Apr'">04</xsl:when>
      <xsl:when test="$mo = 'May'">05</xsl:when>
      <xsl:when test="$mo = 'Jun'">06</xsl:when>
      <xsl:when test="$mo = 'Jul'">07</xsl:when>
      <xsl:when test="$mo = 'Aug'">08</xsl:when>
      <xsl:when test="$mo = 'Sep'">09</xsl:when>
      <xsl:when test="$mo = 'Oct'">10</xsl:when>
      <xsl:when test="$mo = 'Nov'">11</xsl:when>
      <xsl:when test="$mo = 'Dec'">12</xsl:when>
    </xsl:choose>
    <xsl:value-of select="'-'"/>
    <xsl:if test="(string-length($day) &lt; 2)">
      <xsl:value-of select="0"/>
    </xsl:if>
    <xsl:value-of select="$day"/>
    <xsl:value-of select="'T'"/-->
    <xsl:value-of select="$hh"/>
    <xsl:value-of select="':'"/>
    <xsl:value-of select="$mm"/>
    <!--xsl:value-of select="':'"/>
    <xsl:value-of select="$ss"/-->
  </xsl:template>
  
</xsl:stylesheet>