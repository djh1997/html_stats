#!/usr/bin/env bash

#set variables
#get first of 3 temps for average
temp1=$(cat /sys/class/thermal/thermal_zone0/temp)
#set out put file
OF=stats.html
minpwm=200
maxpwm=1023
OC=0
#get the uptime of the server
uptime=$(uptime)
#get temp in deg c
#get load average tail gets the last 11 characters head gets the first 4
load=$(uptime | tail -c 11 | head -c 4)
loadnum=$((${load:0:1}*100+${load:2:1}*10+${load:3:1}))

temp2=$(cat /sys/class/thermal/thermal_zone0/temp)

#cap load at 400% (4 core cpu)
if(($loadnum >= 400)); then loadnum=399; fi
#append load value to log file
echo $((($loadnum*33)/40)) >> loadlist.txt
#get last 1440 values from log file
loadlist=$(tail -1440 loadlist.txt)
#put values into array
loadarr=( $loadlist )
#make variable number that matches lenght of array to make iteration over array easier 
loadarrlength=(${#loadarr[@]})

temp3=$(cat /sys/class/thermal/thermal_zone0/temp)
temp=$((($temp1+$temp2+$temp3)/3))
fanpwm=$((($temp/70)+(loadnum/2)))

if (($fanpwm >= $maxpwm))||(($OC == 1)); then
  fanpwm=$maxpwm
elif (($fanpwm <= $minpwm))||(($OC ==-1)); then
  fanpwm=0
else
	fanpwm=$fanpwm
fi

fanrpm=$(($fanpwm*5))
 
echo $(($temp/100)) >> templist.txt
templist=$(tail -1440 templist.txt)
temparr=( $templist )
temparrlength=(${#temparr[@]})

echo $(($fanpwm/3)) >> fanlist.txt
fanlist=$(tail -1440 fanlist.txt)
fanarr=( $fanlist )
fanarrlength=(${#fanarr[@]})

#get folder sizes 
sizesd=$(df -h / --output=size | egrep -o  '.[0-9]+')
usedsd=$(df -h / --output=used | egrep -o  '.[0-9]+')
pcentsd=$(df / --output=pcent | egrep -o  '[0-9]+')
#size=$(df --block-size=1GB 14tb/ --output=size | egrep -o  '.[0-9]+')
#used=$(df --block-size=1GB 14tb/ --output=used | egrep -o  '[0-9]+')
#seed=$(du -s --block-size=1GB 14tb/seed | head -c 4)
#pcent=$((($used*100)/$size))
#seedusedpcent=$((($seed*100)/$used))
#seedsizepcent=$((($seed*100)/$size))

echo '<!DOCTYPE html><html><head>  <meta http-equiv="refresh" content="60"></head><body>' > $OF
echo $tempc'<meter value="'$temp'" min="25000" low="34000" optimum="25001" high="37000" max="45000"></meter><br>' >> $OF
echo $fanrpm' fan rpm<meter value="'$fanpwm'" low="550" optimum="'$minpwm'" high="750" max="'$maxpwm'"></meter><br>' >> $OF
echo $usedsd'GB used on sd card '$pcentsd'% full<meter value="'$pcentsd'" low="60" optimum="0" high="80" max="100"></meter><br>' >> $OF
echo $used'GB used '$pcent'% full<meter value="'$pcent'" low="60" optimum="0" high="80" max="100"></meter><br>' >> $OF
echo $seed'GB used to seed linux isos '$seedusedpcent'% of used '$seedsizepcent'% of disk<meter value="'$seed'" max="'$used'"></meter><br>' >> $OF
echo $uptime'<meter value="'$load'"low="2"optimum="1"high="3" max="4"></meter><br>' >> $OF
#make 2 part pi chart
echo '<svg height="200" width="200" viewBox="0 0 40 40"><circle class="donut-hole" cx="21" cy="21" r="15.91549430918954" fill="#fff" transform="rotate(90, 21, 21)"></circle><circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="blue" stroke-width="3"/><circle r="15.91549430918954" cx="21" cy="21" fill="transparent" stroke="green" transform="rotate(90, 21, 21)" stroke-width="3" stroke-dasharray="'$pcentsd' '$((100-$pcentsd))'"/><text fill="black" font-size="12" font-family="Verdana"
   x="12" y="25">SD</text></svg>' >> $OF

echo '<br><font color="blue">free</font><font color="red">seed</font><font color="green">used</font><br>' >> $OF
#make the graph background 
echo '<svg height="330" width="'$temparrlength'"><defs>
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
#iterate over temperature array to plot point
for (( i=0; i<$temparrlength; i++ )); do
 echo "$i,$((550-${temparr[$i]})) ">> $OF ;
done

echo '"style="fill:none;stroke:black;stroke-width:1" /><polyline points="' >> $OF

for (( i=0; i<$fanarrlength; i++ )); do
 echo "$i,$((330-${fanarr[$i]})) ">> $OF ;
done

echo '"style="fill:none;stroke:blue;stroke-width:1" /><polyline points="' >> $OF

for (( i=0; i<$loadarrlength; i++ )); do
 echo "$i,$((330-${loadarr[$i]})) ">> $OF ;
done
#finish graph and add label text
echo '"style="fill:none;stroke:purple;stroke-width:1" />  <text fill="blue" font-size="12" font-family="Verdana"
  x="10" y="10">fan speed 0-5000rpm</text>
  <text fill="black" font-size="12" font-family="Verdana"
  x="10" y="20">temp 22-55c</text>
  <text fill="purple" font-size="12" font-family="Verdana"
  x="10" y="30">cpu load 0-100%</text>
</svg><br></body></html>' >> $OF
