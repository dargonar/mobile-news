IMAGES=ElDia/images

declare -a images_dirs=('eldia'  'pregon' 'ecosdiarios' 'castellanos_dark');
declare -a schemes=('ElDia' 'Pregon' 'EcosDiarios' 'Castellanos');

total=${#images_dirs[*]}

# rm -rf apks-to-upload
# mkdir apks-to-upload

for (( j=0; j<=$(( $total -1 )); j++ ))
do

  id=${images_dirs[$j]}
  sc=${schemes[$j]}
  
  cp $IMAGES/$id/*.png ElDia/images/
  cp $IMAGES/$id/Icon~ipad.png ElDia/Icon~ipad.png
  
  cd ElDia/
  
  xcodebuild -scheme $sc -target $sc archive
  
  cd ..
  
done



