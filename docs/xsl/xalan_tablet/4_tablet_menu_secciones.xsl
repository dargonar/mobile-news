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
        <link rel="stylesheet" type="text/css" href="css/layout_tablet.css" />
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout_tablet.css" / -->
        <title>MENU</title>
      </head>
      
      <body class="menu">
        <div id="menu">
          <ul>
            <li class="seccion">Noticias</li>
            <li><a href="section://main">Principal</a></li>
            <xsl:for-each select="rss/channel/item">
              <li><a href="section://{guid}"><xsl:value-of disable-output-escaping="yes" select="title" /></a></li>
            </xsl:for-each>
            
            
            <!-- li><a href="clasificados://" class="seccion">Clasificados</a></li -->
            <li class="seccion">Clasificados</li>
            <li><a href="clasificados://0">Salud</a></li>
            <li><a href="clasificados://1">Alquiler de habitaciones</a></li>
            <li><a href="clasificados://2">Alquiler de inmuebles</a></li>
            <li><a href="clasificados://3">Geriátricos y pensiones</a></li>
            <li><a href="clasificados://4">Compra y venta de inmuebles</a></li>
            <li><a href="clasificados://5">Compra venta y alquiler de neg. ped. socios</a></li>
            <li><a href="clasificados://6">Veterinarias, mascotas</a></li>
            <li><a href="clasificados://7">Compra y venta de automotores</a></li>
            <li><a href="clasificados://8">Compra y venta de motos y accesorios</a></li>
            <li><a href="clasificados://9">Transportes</a></li>
            <li><a href="clasificados://10">Compra y venta art. del hogar (usados)</a></li>
            <li><a href="clasificados://11">Electrónica, música, equipos  y fotografía</a></li>
            <li><a href="clasificados://12">Construcciones, planos y empresas</a></li>
            <li><a href="clasificados://13">Albañilería, pintura, plomería, rep. techos</a></li>
            <li><a href="clasificados://14">Hipotecas, prestamos, transferencias y seguros</a></li>
            <li><a href="clasificados://15">Festejos y guarderías</a></li>
            <li><a href="clasificados://16">Enseñanza de idiomas y traducciones</a></li>
            <li><a href="clasificados://17">Enseñanza particular</a></li>
            <li><a href="clasificados://18">Máquinas de coser, tejer, escribir y calcular</a></li>
            <li><a href="clasificados://19">Materiales de construcción</a></li>
            <li><a href="clasificados://20">Modistas, sastres, talleres, arreglos ropa</a></li>
            <li><a href="clasificados://21">Oficios ofrecidos</a></li>
            <li><a href="clasificados://22">Empleos</a></li>
            <li><a href="clasificados://23">Tarot - astrología - parapsicología</a></li>
            <li><a href="clasificados://24">Extravios y hallazgos</a></li>
            <li><a href="clasificados://25">Personas buscadas</a></li>
            <li><a href="clasificados://26">Personal casa flia. ofrecidos</a></li>
            <li><a href="clasificados://27">Personal casa flia. pedidos</a></li>
            <li><a href="clasificados://28">Service de art. del hogar reparaciones</a></li>
            <li><a href="clasificados://29">Varios</a></li>
            <li><a href="clasificados://30">Art. suntuarios, alhajas, oro</a></li>
            <li><a href="clasificados://31">Cursos varios</a></li>
            <li><a href="clasificados://32">Deportes y camping</a></li>
            <li><a href="clasificados://33">Remates, demoliciones</a></li>
            <li><a href="clasificados://34">Jardinería, plantas y viveros</a></li>
            <li><a href="clasificados://35">Carpintería metalica y madera, puertas, cortinas</a></li>
            <li><a href="clasificados://36">Ferreterías - cerrajerías</a></li>

            <li class="seccion">Varios</li>
            <li><a href="#">Fúnebres</a></li>
            <li><a href="#">Indice de Rubros</a></li>
            <li><a href="#">Receptorías</a></li>
            <li><a href="#">Avisos con Imágenes</a></li>
            <li><a href="#">e-propiedades</a></li>
            <li><a href="#">Motores Argentinos</a></li>
          </ul>
        </div>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>