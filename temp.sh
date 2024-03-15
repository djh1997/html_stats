
OF=temp.svg

templist=$(tail -1440 tempstress.log)
temparr=( $templist )
temparrlength=(${#temparr[@]})

#make the graph background 
echo '<svg height="500" width="'$temparrlength'"><defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%"
      style="stop-color:rgb(255,80,80)" />
      <stop offset="50%"
      style="stop-color:rgb(255,255,80)" />
      <stop offset="100%"
      style="stop-color:rgb(80,255,80)" />
    </linearGradient>
  </defs>
  <rect width="'$temparrlength'" height="500" fill="url(#grad1)" /><path d="' > $OF
#make vertical time axis
for (( i=60; i<1400; i+=60 )); do
 echo 'M'$i' 0L'$i' 500' >> $OF ;
done
#make horizontal 3rd line
echo 'M0 166L1440 166M0 333L1440 333Z"stroke="white"/><polyline points="' >> $OF
#iterate over temperature array to plot point
for (( i=0; i<$temparrlength; i++ )); do
 echo "$i,$((1000-${temparr[$i]}*10)) ">> $OF ;
done

echo '"style="fill:none;stroke:black;stroke-width:1" /><polyline points="' >> $OF

#finish graph and add label text
echo '"style="fill:none;stroke:black;stroke-width:1" />
  <text fill="black" font-size="12" font-family="Verdana"
  x="10" y="20">temp 25-75c</text>
</svg>' >> $OF
