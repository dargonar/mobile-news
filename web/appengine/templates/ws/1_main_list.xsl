{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body onload="update_all_images()">
    {{ cc.UpdatedAt() }}
    {{ cc.DestacadaEnListadoPrincipal(data.item.0) }}
    {{ cc.ListadoNoticiasEnListado(data.item[1:]) }}
  </body>
</html>