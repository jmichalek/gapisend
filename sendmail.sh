#!/bin/bash
# Použití: ./sendmail komu co. Například sendmail vs 2014-08-23-pozvanka-na-tk.txt

skupina=$(case $1 in
  "rp") echo "Republikove%20predsednictvo" ;;
  "rv") echo "Republikovy%20vybor" ;;
  "praha") echo "KS%20Praha" ;;
  "regp-praha") echo "RegP%20Praha" ;;
  "vs") echo "Volebni%20stab%20Praha" ;;
esac)

cesta="http://graph.pirati.cz/group/"$skupina"/members"
until members=$(curl -s $cesta)
do
  sleep 10
done
echo $members | jq -r '.[].id' > members.txt
echo "Nahrán seznam členů\n"

recipients=""

while read -r line           
do           
     cesta="http://graph.pirati.cz/"$line""
     until clovek=$(curl -s $cesta)
     do
       sleep 10
     done
     username=$(echo -n $clovek | jq -r '.username');
     echo "Stažen uživatel $username \n"
     recipients="$recipients $(echo -n $(echo -n $username | iconv -f UTF8 -t ASCII//TRANSLIT | sed 's/ /./g' | sed 's/[^a-zA-Z0-9._-]//g')"@pirati.cz ")"
done <"members.txt"

rm members.txt

cat $2 | msmtp -t $recipients
