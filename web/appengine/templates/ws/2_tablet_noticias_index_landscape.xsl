{% import 'ws/functions_ex.xsl' as cc %}
<html>
  {{ cc.Head('layout_tablet') }}
  <body class="menu landscape" onload="update_all_images()">
    <div id="landscape">
      <div class="seccion list">Principal</div>
      <div class="menu">
        <ul class="landscape_news_list">
        {{ cc.tablet_news_list_landscape(data.item) }}
        </ul>
      </div>
    </div>
  </body>
</html>