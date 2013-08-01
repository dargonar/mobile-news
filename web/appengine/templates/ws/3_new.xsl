{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body onload="update_imagen_nota_abierta()">
    {{ cc.NotaAbierta(data.item) }}

    {% if data.item.related %}
      {{ cc.TituloSeccionONotisRelac('Noticias relacionadas') }}
      {{ cc.ListadoNoticiasRelacionadas(data.item.related|build_list) }}
    {% endif %}
  </body>
</html>