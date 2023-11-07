#!/usr/bin/env bash

#set out put file
OF=/var/www/html/track.html

gpslist=$(tail -1440 /home/pi/gpslist.txt)
#put values into array
gpsarr=( $gpslist )
#make variable number that matches lenght of array to make iteration over array easier 
gpsarrlength=(${#gpsarr[@]})



cat '<!DOCTYPE html><html><head>  <meta http-equiv="refresh" content="60"></head><body>' > $OF


#make the graph background 
echo '<svg height="330" width="300"><defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%"
      style="stop-color:rgb(255,80,80)" />
      <stop offset="50%"
      style="stop-color:rgb(255,255,80)" />
      <stop offset="100%"
      style="stop-color:rgb(80,255,80)" />
    </linearGradient>
  </defs>
  <rect width="'$temparrlength'" height="330" fill="url(#grad1)" /><path d="' >> $OF
#make vertical time axis
for (( i=60; i<1400; i+=60 )); do
 echo 'M'$i' 0L'$i' 360' >> $OF ;
done
#make horizontal 3rd line
echo 'M0 83L1440 83M0 166L1440 166M0 249L1440 249Z"stroke="white"/><polyline points="' >> $OF
#iterate over gps array to plot point

for (( i=0; i<$gpsarrlength; i++ )); do
 echo "$(${gpsarr[$i][0]}),$(${gpsarr[$i][1]}) ">> $OF ;
done
#finish graph and add label text
echo '"style="fill:none;stroke:purple;stroke-width:1" />  <text fill="blue" font-size="12" font-family="Verdana"
  x="10" y="10">fan speed 0-5000rpm</text>
  <text fill="black" font-size="12" font-family="Verdana"
  x="10" y="20">temp 22-55c</text>
  <text fill="purple" font-size="12" font-family="Verdana"
  x="10" y="30">cpu gps 0-100%</text>
</svg></a><br></body></html>' >> $OF
