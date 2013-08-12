{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body onload="onLoad('{{page_name}}')" class="menu">
    <div id="menu">
      <ul>
        <li class="seccion">Noticias</li>
        <li><a href="section://main">Principal</a></li>
        {% for item in data.item %}
        <li><a href="section://{{item.guid.value}}">{{item.title}}</a></li>
        {% endfor %}
       
        {% if cfg.has_clasificados %} 
        <li class="seccion"> <a class="no_style" href="#" onclick="return toggle('ul_clasificados', 'invisible');" >Clasificados</a></li>
        {% endif %}
      </ul>
      {% if cfg.has_clasificados %} 
      <ul class="invisible" id="ul_clasificados">
        {% for id, desc in cfg.clasificados.iteritems() %}
        <li><a class="vip2" href="clasificados://{{id}}">{{desc}}</a></li>
        {% endfor %}
      </ul>
      {% endif %}

      {% if cfg.has_funebres or cfg.has_farmacia or cfg.has_cartelera %}      
      <ul>
        <li class="seccion"> <a class="no_style" href="#" onclick="return toggle('ul_varios', 'invisible');" >Servicios varios</a></li>
      </ul>
      <ul class="invisible" id="ul_varios">
        {% if cfg.has_funebres %}
        <li><a class="vip2" href="funebres://full">Fúnebres</a></li>
        {% endif %}

        {% if cfg.has_farmacia %}
        <li><a class="vip2" href="farmacia://full">Farmacias de turno</a></li>
        {% endif %}

        {% if cfg.has_cartelera %}
        <li><a class="vip2" href="cartelera://full">Cartelera de cine</a></li>
        {% endif %}
      </ul>
      {% endif %}

    </div>

  </body>
</html>