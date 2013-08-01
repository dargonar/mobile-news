{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body onload="update_imagen_nota_abierta()" class="portrait padded global">
  {{ cc.tablet_open_new_global(data.item) }}
  </body>
</html>