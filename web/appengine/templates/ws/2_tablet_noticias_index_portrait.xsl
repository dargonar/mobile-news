{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body class="menu portrait" onload="update_all_images()">
    <div id="index">
      <div class="seccion list">Principal</div>
      <div class="menu portrait_news_list_container">
        {% set list_width = data.item|length * 192 %}
        <ul class="portrait_news_list" style="width:{{list_width}}px;">
          {{ cc.tablet_news_list_landscape(data.item) }}
        </ul>
      </div>
    </div>
  </body>
</html>