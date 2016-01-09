#!/bin/bash

############################################################################
#
#	This script is for merging two feeds into one.
#	If you have more feeds you want to merge, just reuse this script
#	recursive on the same destination feed.
#
#	Author: Sebi	Mail: sebi [ at ] tuximail.de
#
#############################################################################



##############################################################################
#
#	Usage: feedmerger.sh feed1.xml feed2.xml
#	The script will create a file as defined in var "zielfeed"
#	in which both feeds will be combined and sorted after date.
#
#	The Header is specified for the "podlove" tool and its namespaces
#
##############################################################################	

##############################################################################
#
#	TODO: Fill the header of the XML File. (Every EDIT in the first
#	section of the file
#
#############################################################################


feeds=( ${1} ${2} )
zielfeed="mergefeed.xml"

date=$(date)
echo "<?xml version='1.0' encoding='utf-8'?>
<rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'
	xmlns:bitlove='http://bitlove.org' xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd' xmlns:psc='http://podlove.org/simple-chapters' xmlns:content='http://purl.org/rss/1.0/modules/content/' xmlns:fh='http://purl.org/syndication/history/1.0'>
<channel>
<generator>Feedmerger https://github.com/todestoast/scripts/blob/master/feedmerger.sh</generator>
<title>EDIT</title>
<description>EDIT</description>
<link>EDIT</link>
<image><url>EDIT</url><title>EDIT</title><link>EDIT</link></image>0<language>de-de</language>
<pubDate>$date </pubDate>" > $zielfeed

## write dates of all feeds into textfile, sort them and write the correspondings orders into the dest. file

for ix in ${!feeds[*]}
do    

while read -r line ; do
	
    echo -e ${feeds[$ix]} "\t" ${line} >> /tmp/feed-datum.txt
    
done< <(sed -n '/<item>/,/<\/item>/p' ${feeds[$ix]} | grep -i pubdate | sed 's/<pubDate>//g' | sed 's/<\/pubDate>//g')   
    
done

cat /tmp/feed-datum.txt | cut -f2 |  while read line; do echo $(date -d "$line" +%s)" # "$line; done | sort | sed 's/.* # //' >> /tmp/sorted_dates

#amount of appearances of each feed

for ix in ${!feeds[*]}
do    

export anzahl=$(cat /tmp/feed-datum.txt | cut -f1 | grep -i ${feeds[$ix]} | wc -l)

echo -e ${feeds[$ix]} "\t" $anzahl >> /tmp/feedanzahl

done

inhalt=$(cat /tmp/sorted_dates | wc -c)

a=1
i=1

while ! [[ $inhalt -eq 0 ]] 
do

	#read the date of the last line 
	date=$(tail -1 /tmp/sorted_dates)

	#delete the last line
	sed -i '$ d' /tmp/sorted_dates

	#search for the date in both files
	file=$(cat /tmp/feed-datum.txt | grep -i "${date}"  | cut -f1 | tr -d ' ')

	#write the found line in the dest. file
	
	if [ "$file" == ${feeds[0]} ]
	then
		cat $file | sed '/<item>/{x;s/^/X/;/^X\{'$i'\}$/ba;x};d;:a;x;:b;$!{n;/<\/item>/!bb}' >> $zielfeed
		export i=$((i+1))
	fi
	
	if [ "$file" == ${feeds[1]} ]
	then
		cat $file | sed '/<item>/{x;s/^/X/;/^X\{'$a'\}$/ba;x};d;:a;x;:b;$!{n;/<\/item>/!bb}' >> $zielfeed
		export a=$((a+1))
	fi
	
	inhalt=$(cat /tmp/sorted_dates | wc -c)

done

echo "</channel>
</rss>" >> $zielfeed

rm /tmp/sorted_dates
rm /tmp/feedanzahl
rm /tmp/feed-datum.txt
