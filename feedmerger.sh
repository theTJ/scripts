#!/bin/bash

feeds=("/home/sebi/podcasts/ragecast.rss" "/home/sebi/podcasts/bewegtton/bewegtton-rss.xml")

export feedanzahl=${#feeds[*]}

## Datum von allen Feeds in textfile schreiben, dort anordnen danach auf Feeds übertragen

for ix in ${!feeds[*]}
do    

while read -r line ; do
	
    echo -e ${feeds[$ix]} "\t" ${line} >> blabla.txt
    
done< <(sed -n '/<item>/,/<\/item>/p' ${feeds[$ix]} | grep -i pubdate | sed 's/<pubDate>//g' | sed 's/<\/pubDate>//g')   
    
done

cat blabla.txt | cut -f2 |  while read line; do echo $(date -d "$line" +%s)" # "$line; done | sort -r | sed 's/.* # //' >> /tmp/sorted_dates

#anzahl vorkommen jedes feeds

for ix in ${!feeds[*]}
do    

export anzahl=$(cat blabla.txt | cut -f1 | grep -i ${feeds[$ix]} | wc -l)

echo -e ${feeds[$ix]} "\t" $anzahl >> /tmp/feedanzahl

#datei: feed \t feedanzahl

done


#line=$(head -n 1 /tmp/sorted_dates)

#die betroffene zeile

#cat blabla.txt | grep -i $line | cut -f1

#position x aus Datei in mergedfeed schreiben

anzahlfeed1=$(cat /tmp/feedanzahl| grep -i ${feeds[0]} | cut -f2 | sed -e 's/^[ \t]*//')


anzahlfeed2=$(cat /tmp/feedanzahl| grep -i ${feeds[1]} | cut -f2 | sed -e 's/^[ \t]*//')

date=$(tail -1 /tmp/sorted_dates)
file=$(cat blabla.txt | grep -i "${date}" | cut -f1)


#wenn File == feed1
while ! [[ $anzahlfeed1 -eq 0 && $anzahlfeed2 -eq 0 ]] 
do

echo "abfrage1: $file"
echo "${feeds[0]}"
if [ "$file" == "${feeds[0]}" ]
then
echo "feed1"
	
	# wir lesen das datum der letzten Zeile
	date=$(tail -1 /tmp/sorted_dates)

	#wir löschen die letzte zeile
	sed -i '$ d' /tmp/sorted_dates

	#wir suchen die Zeile mit dem Datum in beiden Files
	file=$(cat blabla.txt | grep -i $date | cut -f1)

	#wir schreiben die gefundene Zeile in den mergefeed

	cat $file | sed '/^<item>/{x;s/^/X/;/^X\{3\}$/ba;x};d;:a;x;:b;$!{n;/^<\/item>/!bb}' >> mergefeed.xml
	echo "in mergefeed geschrieben"
	export anzahlfeed1 = $(($anzahlfeed1-1))
fi

echo "abfrage2: $file"
echo "${feeds[1]}"
if [ "$file" == "${feeds[1]}" ]
then
echo "feed2"
	# wir lesen das datum der letzten Zeile
	date=$(tail -1 /tmp/sorted_dates)

	#wir löschen die letzte zeile
	sed -i '$ d' /tmp/sorted_dates

	#wir suchen die Zeile mit dem Datum in beiden Files
	file=$(cat blabla.txt | grep -i $date | cut -f1)

	#wir schreiben die gefundene Zeile in den mergefeed

	cat $file | sed '/^<item>/{x;s/^/X/;/^X\{3\}$/ba;x};d;:a;x;:b;$!{n;/^<\/item>/!bb}' >> mergefeed.xml
	echo "in mergefeed geschrieben"
	export anzahlfeed2 = $(($anzahlfeed2-1))
fi
done


#wir brauchen feedanzahl beider feeds

#alle runterzählen, bis alle 0 sind.

##zugriff auf dritte Position

#sed '/^<item>/{x;s/^/X/;/^X\{3\}$/ba;x};d;:a;x;:b;$!{n;/^<\/item>/!bb}'



##parse items

#sed -n '/<item>/,/<\/item>/p'




