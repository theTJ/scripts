#!/bin/bash

#Aktuelle Auslegung: 2 Feeds
#
#Todo: - feeds mit den Pfaden versehen
# - versichern, dass Schreibrechte auf /tmp, sowie das aktuelle Verzeichnis existieren
# - mit AUSZUFÜLLEN gekennzeichnete Einträge passend ergänzen


feeds=("/path/to/feed1.xml" "/path/to/feed2.xml")
zielfeed="mergefeed.xml"

date=$(date)
echo "<?xml version='1.0' encoding='utf-8'?>
<rss version='2.0'>
<channel>
<generator>Feedmerger https://github.com/todestoast/scripts/blob/master/feedmerger.sh</generator>
<title>AUSZUFÜLLEN</title>
<description>AUSZUFÜLLEN</description>
<link>AUSZUFÜLLEN</link>
<image><url>AUSZUFÜLLEN</url><title>AUSZUFÜLLEN</title><link>AUSZUFÜLLEN</link></image>0<language>de-de</language>
<pubDate>$date </pubDate>" > $zielfeed

#export feedanzahl=${#feeds[*]}

## Datum von allen Feeds in textfile schreiben, dort anordnen danach auf Feeds übertragen

for ix in ${!feeds[*]}
do    

while read -r line ; do
	
    echo -e ${feeds[$ix]} "\t" ${line} >> /tmp/feed-datum.txt
    
done< <(sed -n '/<item>/,/<\/item>/p' ${feeds[$ix]} | grep -i pubdate | sed 's/<pubDate>//g' | sed 's/<\/pubDate>//g')   
    
done

cat /tmp/feed-datum.txt | cut -f2 |  while read line; do echo $(date -d "$line" +%s)" # "$line; done | sort -r | sed 's/.* # //' >> /tmp/sorted_dates

#anzahl vorkommen jedes feeds

for ix in ${!feeds[*]}
do    

export anzahl=$(cat /tmp/feed-datum.txt | cut -f1 | grep -i ${feeds[$ix]} | wc -l)

echo -e ${feeds[$ix]} "\t" $anzahl >> /tmp/feedanzahl

#datei: feed \t feedanzahl

done

inhalt=$(cat /tmp/sorted_dates | wc -c)

# Anzahl der <item>s pro Feed
#a=$(cat /tmp/feedanzahl| grep -i ${feeds[0]} | cut -f2 | sed -e 's/^[ \t]*//')
#i=$(cat /tmp/feedanzahl| grep -i ${feeds[1]} | cut -f2 | sed -e 's/^[ \t]*//')
a=0
i=0

while ! [[ $inhalt -eq 0 ]] 
do

	# wir lesen das datum der letzten Zeile
	date=$(tail -1 /tmp/sorted_dates)
	echo "date: $date"

	#wir löschen die letzte zeile
	sed -i '$ d' /tmp/sorted_dates

	#wir suchen die Zeile mit dem Datum in beiden Files
	file=$(cat /tmp/feed-datum.txt | grep -i "${date}"  | cut -f1 | tr -d ' ')
	echo "file: $file"

	#wir schreiben die gefundene Zeile in den mergefeed
	
	if [ "$file" == feeds[0] ]
	then
		cat $file | sed '/^<item>/{x;s/^/X/;/^X\{'$i'\}$/ba;x};d;:a;x;:b;$!{n;/^<\/item>/!bb}' >> $zielfeed
		export i=$((i+1))
		echo "----i: $i"
	fi
	
	if [ "$file" == feeds[1] ]
	then
		cat $file | sed '/^<item>/{x;s/^/X/;/^X\{'$a'\}$/ba;x};d;:a;x;:b;$!{n;/^<\/item>/!bb}' >> $zielfeed
		export a=$((a+1))
		echo "----a: $a"
	fi
	
	inhalt=$(cat /tmp/sorted_dates | wc -c)

done

echo "</channel>
</rss>" >> $zielfeed

rm /tmp/sorted_dates
rm /tmp/feedanzahl
rm /tmp/feed-datum.txt



