function update_image(img) {
  var el = document.getElementById(img);
  el.style.backgroundImage = ''; 
  el.style.backgroundImage = 'url(i_' + img + ')';
}

function update_all_images() {
  refresh_background(document.getElementsByClassName('imagen_principal'));
  refresh_background(document.getElementsByClassName('imagen_secundaria'));
}

function refresh_background(imgs) {
  for (var i = 0; i < imgs.length; ++i) {
    var img = imgs[i];
    var url = img.style.backgroundImage;
    img.style.backgroundImage = '';
    img.style.backgroundImage = url;
  }
}