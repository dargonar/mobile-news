{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body onload="onLoad('{{page_name}}')" class="portrait padded">
    {{ cc.UpdatedAt() }}
    <div id="index" class="padded_landscape top_padded">
      {{ cc.tablet_index_portrait_secondary(data.item[0:2]) }}
      {{ cc.tablet_index_portrait_terciary(data.item[2:]) }}
    </div>
  </body>
</html>