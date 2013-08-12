{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body onload="onLoad('{{page_name}}')">
    {{ cc.UpdatedAt() }}
    <div id="titulo_seccion">
      <label class="lbl_titulo_seccion">{{data.item.0.category}}</label>
    </div>
    {{ cc.ListadoNoticiasEnListado(data.item) }}
  </body>
</html>
