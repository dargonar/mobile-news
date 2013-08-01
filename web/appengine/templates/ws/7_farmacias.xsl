{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout') }}
  <body>
    <div id="clasificados">
      <div class="columna">
        <div class="encabezado">
          <div class="rubro">Farmacias de turno</div>
          <div class="clear"></div>
          <div class="titulo"></div>
          {{ cc.DateMonthYear(data) }}
          <div class="clear"></div>
        </div>

        <div class="aviso" id="farmacia_list">
        {{data.item}}
        </div>
      </div>  
    </div>
  </body>
</html>