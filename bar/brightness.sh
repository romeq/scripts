current="$(brightnessctl g -q)"
max="$(brightnessctl m -q)"

echo ": $(echo $current $max | awk '{print int(($1/$2)*100)}')%"
