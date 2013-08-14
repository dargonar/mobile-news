{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body class="menu" style="margin:0;" onload="onLoad('{{page_name}}')">
    <div id="menu">
      <div class="menu-header">Secciones</div>
      <ul>
        <li><a href="section://main">Principal</a></li>
        {% for item in data.item %}
        <li><a href="section://{{item.guid.value}}">{{item.title}}</a></li>
        {% endfor %}
        
        {% if cfg.has_clasificados %}
        <li><a class="vip2" href="clasificados://list">Clasificados</a></li>
        {% endif %}
        
        {% if cfg.has_funebres %}
        <li><a class="vip2" href="funebres://">Fúnebres</a></li>
        {% endif %}

        {% if cfg.has_farmacia %}
        <li><a class="vip2" href="farmacia://">Farmacias de turno</a></li>
        {% endif %}
        
        {% if cfg.has_cartelera %}
        <li><a class="vip2" href="cartelera://">Cartelera de cine</a></li>
        {% endif %}

        <li class="vip2_close"></li>
      </ul>
    </div>

  </body>
</html>