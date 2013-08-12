{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body onload="onLoad('{{page_name}}')" class="portrait padded">
    {{ cc.UpdatedAt() }}
    {% if not data.item.0.thumbnail %}      
      <div id="index" class="padded_landscape top_padded">
        {{ cc.tablet_index_portrait_secondary(data.item[0:2]) }}
        {{ cc.tablet_index_portrait_terciary(data.item[2:]) }}
      </div>
    {% else %}
      <div id="index" class="padded_landscape">
        {{ cc.tablet_index_portrait_main(data.item.0) }}
        {{ cc.tablet_index_portrait_secondary(data.item[1:3]) }}
        {{ cc.tablet_index_portrait_terciary(data.item[3:]) }}
      </div>
    {% endif %}
  </body>
</html>