#!/bin/bash
[[ $# -ne 1 ]] && echo Usage: $0 "<inputFile>" && exit -1

inputFile=$1

sed -i 's/@/ @ /g' ${inputFile}

echo "<html>"
echo "<head>"
echo "<style>"

cat $(dirname $0)/csv2html.css

echo "</style>"

echo "</head>"
echo "<body>"
echo "{{TITOLO}}"
echo "{{SOTTOTITOLO}}"
echo "{{TITOLETTO}}"
echo "<table class=\"styled-table\">"

head -n 1 ${inputFile} | \
    sed -e 's/^/<tr><th>/' -e 's/|/<\/th><th>/g' -e 's/$/<\/th><\/tr>/'

n=1
a=false
while read line; do
  # reading each line
  if [[ $a == true ]]; then
    echo ${line} | sed -e 's/^/<tr class="active-row"><td>/' -e 's/|/<\/td><td>/g' -e 's/$/<\/td><\/tr>/'
  else
    echo ${line} | sed -e 's/^/<tr><td>/' -e 's/|/<\/td><td>/g' -e 's/$/<\/td><\/tr>/'
  fi
  n=$((n+1))
  if [[ $n -eq 3 ]]; then
    if [[ $a == false ]]; then a=true
    else a=false; fi
    n=1
  fi
done < <(tail -n +2 ${inputFile})

echo "</table>"

echo "<footer>"
echo "<p><small><a href="https://github.com/mapuricelli/jms_queue_report" target="_blank">JMS Queue Report</a></small></p>"
echo '<p><small><a href="mailto:manuel.puricelli@ags-it.com?subject=[JMS&nbsp;Queue&nbsp;Report]&nbsp;Info&nbsp;progetto">M. Puricelli</a></small></p>'
echo "</footer>"

echo "</body></html>"
