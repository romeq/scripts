used="$(free --mega | grep Mem | awk '{print $3/1000}' | cut -c 1-3)"

echo " $used Gb"
