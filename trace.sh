cription:												    #
# Ce script a pour but de tracer le chemin d'un paquet et d'en créer un cartographie.			    #
# 													    #
# Le script pourra tracer la route du paquet avec differents protocoles et sur différents numéros de ports. #
#													    #
# Outils utilisés:  traceroute, xdot, cut, grep, sed.							    #
# 													    #
#############################################################################################################


# Cette boucle permet de vérifier la présence d'un argument.  
if [ -z $1 ]						      
then 						      
	echo " Pas de paramètre "		      
	exit -1
fi						      
clear

################################################################
#  Permet de trouver l'adresse IP sur laquel debute le paque   #
################################################################
tshark -a duration:5 -Y icmp host $1 > me.txt | ping $1 -c 3
host="$(cat me.txt | cut -c 4-| head -n 1 | cut -d " " -f 6)"
echo $host

rm me.txt 
################################################################ 
ipTrgt=$1
fileNm="$(echo $ipTrgt | sed 's/\./\-/g').route"


echo -n  '"'"$host"'"' "-- " > $fileNm

ttl=1
hop=""
hopN1=""
listArg=( "-I" "-T -p 22" "-T -p 80" "-T -p 443" "-U -p 1194" "-U -p 5060"  )


for ttl in $(seq 1 30)  
do
	for proto in "${listArg[@]}" 
	do
		hop=$( traceroute -f $ttl -m $ttl -q 1 $proto $IpCible -n | grep -v traceroute | cut -c 5- | cut -d " " -f 1  )
		hopN1=$(traceroute -A -f $(($ttl+1)) -m $(($ttl+1)) -q 1 $proto $IpCible -n |grep -v traceroute | cut -c 5- | cut -d " " -f 1,2  )
																																							
		if [ "$Hop" == "$IpCible" ]
		then   
			echo -n  '"'" $Hop "'"'"; " >> $NomFichier
			break 2
		elif [ "$Hop" == "*" ] && [ "$proto" == "-I" ] && [ "$HopPlusUn" == "*" ]
		then
			echo -n " Inconnuedesaut$ttl" >> $NomFichier
			echo -n " -- "'"' "Inconnuedesaut$ttl" '"'" -- " >> $NomFichier
			break
		elif [ "$Hop" == "*" ] && [ "$proto" == "-I" ] && [ "$HopPlusUn" != "*" ]
		then
			echo -n " Inconnuedesaut$ttl" >> $NomFichier
			echo -n " -- "'"' "Réseau avant $HopPlusUn & saut $ttl & adresse finale $IpCible" '"'" -- " >> $NomFichier
			break
		elif [ "$Hop" != "*" ] && [ "$Hop" != "$IpCible" ]
		then
			echo -n  '"'" $Hop "'"'  >> $NomFichier
			echo -n " -- "'"' "Réseau avant $HopPlusUn & saut $ttl & adresse finale $IpCible" '"'" -- " >> $NomFichier
			break
		fi
	done
done

																																																																																																																																# Deuxieme ligne	
																																																																																																																																	echo "" >> $NomFichier
																																																																																																																																		for ttl2 in $(seq 1 $ttl)
																																																																																																																																					do	
																																																																																																																																									if [ "$ttl2" == "$ttl" ]
																																																																																																																																													then
																																																																																																																																																		echo -n " $(cat $NomFichier |grep $Moi | sed 's/ -- / -/g' | cut -d "-" -f $((($ttl2*2)+1)) )" >> test
																																																																																																																																																					else

																																																																																																																																																										echo -n " , $(cat $NomFichier |grep $Moi | sed 's/ -- / -/g' |sed 's/;/ -/g' | cut -d "-" -f $((($ttl2*2)+1)) )" >> test
																																																																																																																																																												fi
																																																																																																																																																														done
																																																																																																																																																															echo -n " [shape=ellipse,fontcolor=white,fixedsize=true];" >> test
																																																																																																																																																																echo -n "$(cat test | sed -e 's/ /"'$Moi'" /')" >> $NomFichier
																																																																																																																																																																	echo ""	>> $NomFichier
																																																																																																																																																																		echo "$(cat $NomFichier | sed 's/'[*]'/[65535]/g')" > $NomFichier
																																																																																																																																																																		rm test
