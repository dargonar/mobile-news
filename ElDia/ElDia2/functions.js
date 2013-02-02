function update_image(img) {
  var el = document.getElementById(img);
  if(el==null)
  {
    update_nota_abierta_image(img);
    return;
  }
  el.style.backgroundImage = '';
  el.style.backgroundImage = 'url(i_' + img + ')';
}

function update_all_images() {
  refresh_background(document.getElementsByClassName('imagen'));
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

function update_nota_abierta_image(img){
  var el = document.getElementById('img_'+img);
  //el.src = '';
  //el.src = 'url(i_' + img + ')';
  refresh_background([el]);
}

function update_imagen_nota_abierta(){
  var imgs = document.getElementsByClassName('imagenNotaAbierta');
  for (var i = 0; i < imgs.length; ++i) {
    var img = imgs[i];
    var url = img.src;
    img.src = '';
    img.src = url;
  }
}

var timeout_var=null;
function show_actualizado(msg){
  clearTimeout(timeout_var);
  var el = document.getElementById('updated_msg');
  if(!el)
    return;
  el.innerHTML = msg;
  el.style.display = 'block';
  timeout_var=setTimeout(function(){el.style.display = 'none';},3000);
}
