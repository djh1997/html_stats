#!/usr/bin/env bash

#set out put file
OF=track.html

gpslist=$(tail -1440 gpslist.txt)
#put values into array
gpsarr=( $gpslist )
#make variable number that matches lenght of array to make iteration over array easier
gpsarrlength=(${#gpsarr[@]})

echo '<!DOCTYPE html><html><body>' > $OF

#make the graph background
echo '<svg viewBox="-100 -100 100 100" height="330" width="300"><polyline points="' >> $OF
#iterate over gps array to plot point

for (( i=0; i<$gpsarrlength; i++ )); do
 echo ${gpsarr[$i]:9:12}','${gpsarr[$i]:21:12}' ' >> $OF ;
done
#finish graph and add label text
echo '"style="fill:none;stroke:purple;stroke-width:1" />
</svg></body></html>' >> $OF
