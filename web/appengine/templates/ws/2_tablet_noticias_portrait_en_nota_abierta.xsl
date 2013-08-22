{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body class="menu portrait" onload="onLoad('{{page_name}}')">
    <div id="index">
      <div class="seccion list">{{'Principal' if '://main' in page_name else data.item.0.category }}</div>
      <div class="menu portrait_news_list_container">
        {% set list_width = data.item|length * 192 %}
        <ul class="portrait_news_list" style="width:{{list_width}}px;">
          {{ cc.tablet_news_list_landscape(data.item, raw_url) }}
        </ul>
      </div>
    </div>
  </body>
</html>