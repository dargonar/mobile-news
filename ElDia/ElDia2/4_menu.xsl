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
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <!-- meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" / -->
        <link rel="stylesheet" type="text/css" href="css/layout.css" />
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout.css" / -->
        <title>MENU</title>
      </head>
      
      <body class="menu">
        <div id="menu">
          <div class="menu-header">Secciones</div>
          <ul>
            <!--li class="open"></li-->
            <li><a href="section://main">Principal</a></li>
            <xsl:for-each select="rss/channel/item">
              <li><a href="section://{guid}"><xsl:value-of disable-output-escaping="yes" select="title" /></a></li>
            </xsl:for-each>
            <li class="close"></li>
          </ul>
          
          <div class="menu-header">Clasificados</div>
          <!-- http://www.eldia.com.ar/mc/clasi_rss.aspx?idr=id_rubro&app=1 -->
          <ul class="clasificados">
            <li><a href="clasificados://0">SALUD</a></li>
            <li><a href="clasificados://1">ALQUILER DE HABITACIONES</a></li>
            <li><a href="clasificados://2">ALQUILER DE INMUEBLES</a></li>
            <li><a href="clasificados://3">GERIATRICOS Y PENSIONES</a></li>
            <li><a href="clasificados://4">COMPRA Y VENTA DE INMUEBLES</a></li>
            <li><a href="clasificados://5">COMPRA VENTA Y ALQUILER DE NEG. PED. SOCIOS</a></li>
            <li><a href="clasificados://6">VETERINARIAS, MASCOTAS</a></li>
            <li><a href="clasificados://7">COMPRA Y VENTA DE AUTOMOTORES</a></li>
            <li><a href="clasificados://8">COMPRA Y VENTA DE MOTOS Y ACCESORIOS</a></li>
            <li><a href="clasificados://9">TRANSPORTES</a></li>
            <li><a href="clasificados://10">COMPRA Y VENTA ART. DEL HOGAR (USADOS)</a></li>
            <li><a href="clasificados://11">ELECTRONICA, MUSICA, EQUIPOS  Y FOTOGRAFIA</a></li>
            <li><a href="clasificados://12">CONSTRUCCIONES, PLANOS Y EMPRESAS</a></li>
            <li><a href="clasificados://13">ALBAÑILERÍA, PINTURA, PLOMERIA, REP. TECHOS</a></li>
            <li><a href="clasificados://14">HIPOTECAS, PRESTAMOS, TRANSFERENCIAS Y SEGUROS</a></li>
            <li><a href="clasificados://15">FESTEJOS Y GUARDERIAS</a></li>
            <li><a href="clasificados://16">ENSEÑANZA DE IDIOMAS Y TRADUCCIONES</a></li>
            <li><a href="clasificados://17">ENSEÑANZA PARTICULAR</a></li>
            <li><a href="clasificados://18">MAQUINAS DE COSER, TEJER, ESCRIBIR Y CALCULAR</a></li>
            <li><a href="clasificados://19">MATERIALES DE CONSTRUCCION</a></li>
            <li><a href="clasificados://20">MODISTAS, SASTRES, TALLERES, ARREGLOS ROPA</a></li>
            <li><a href="clasificados://21">OFICIOS OFRECIDOS</a></li>
            <li><a href="clasificados://22">EMPLEOS</a></li>
            <li><a href="clasificados://23">TAROT-ASTROLOGIA-PARAPSICOLOGIA</a></li>
            <li><a href="clasificados://24">EXTRAVIOS Y HALLAZGOS</a></li>
            <li><a href="clasificados://25">PERSONAS BUSCADAS</a></li>
            <li><a href="clasificados://26">PERSONAL CASA FLIA. OFRECIDOS</a></li>
            <li><a href="clasificados://27">PERSONAL CASA FLIA. PEDIDOS</a></li>
            <li><a href="clasificados://28">SERVICE DE ART. DEL HOGAR REPARACIONES</a></li>
            <li><a href="clasificados://29">VARIOS</a></li>
            <li><a href="clasificados://30">ART. SUNTUARIOS, ALHAJAS, ORO</a></li>
            <li><a href="clasificados://31">CURSOS VARIOS</a></li>
            <li><a href="clasificados://32">DEPORTES Y CAMPING</a></li>
            <li><a href="clasificados://33">REMATES, DEMOLICIONES</a></li>
            <li><a href="clasificados://34">JARDINERIA, PLANTAS Y VIVEROS</a></li>
            <li><a href="clasificados://35">CARPINTERIA METALICA Y MADERA, PUERTAS, CORTINAS</a></li>
            <li><a href="clasificados://36">FERRETERIAS - CERRAJERIAS</a></li>
          </ul>
        </div>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>