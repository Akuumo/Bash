#!/bin/bash

ttls()
{
	argLst=( "-I" "-T -p 22" "-T -p 80" "-T -p 443" "-U -p 1194" "-U -p 5060" )
	prtLst=( "ICMP" "TCP 22" "TCP 80" "TCP 443" "UDP 1194" "UDP 5060" )

	for ttl in $(seq 1 30)  
	do
		getIpAddr "$ttl" argLst[@] "$ipT" prtLst[@]
		if [ $code == 0 ]
		then
			return 0
		fi	
	done	
}

getIpAddr()
{
	ttl=$1
	declare -a prots=("${!2}")	
	ipT=$3
	declare -a prtnm=("${!4}")	
	#echo "traceroute -f $ttl -m $ttl -q 1 $prot $ipT -n | grep -v traceroute | cut -c 5- | cut -d \" \" -f 1" 

	for prot in "${prots[@]}"  
	do
		hop="$(traceroute -f $ttl -m $ttl -q 1 $prot $ipT -n | grep -v traceroute | cut -c 5- | cut -d " " -f 1)"
		
		if [ "'$hop'" != "'*'" ]
		then
			echo "$ttl) Success $hop with $prot"
			nmap -Pn -A -T4 $hop

			if [ $hop == $ipT ]
			then 
				code=0
				return $code
			else
				code=1
				return $code
			fi	
		else
			echo "$ttl) Echec with $prot"
		fi
		
	done
	echo "?"
	return -1
}

if [ -z $1 ]						      
then 						      
	echo " Pas de paramètre "		      
	exit -1
fi						      
clear

################################################################
#  Permet de trouver l'adresse IP sur laquel debute le paque   #
################################################################
#tshark -a duration:5 -Y icmp host $1 > me.txt | ping $1 -c 3
#host="$(cat me.txt | cut -c 4-| head -n 1 | cut -d " " -f 6)"
#echo $host

#rm me.txt 
################################################################ 

#fileNm="$(echo $ipTrgt | sed 's/\./\-/g').route"
#echo -n  '"'"$host"'"' "-- " > $fileNm

ipT=$1
ttls "$ipT"
