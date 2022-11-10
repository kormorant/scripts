#!/bin/bash
# Script currently only supports IPv4 and one NIC.
IPSUB=$(ip -4 a | grep 'inet ' | grep -v '127' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3}')
echo 'Your IP address is' $IPSUB
# Check whether the detected IP is the IP that should be used.
echo 'In some cases, the script finds two IP adresses. It is too dumb to differentiate between either. Please indicate "no" below, and fill in the IP address manually.'
read -p 'Do you want to use this IP? (Y/n)' YN
if [[ $YN == 'Y' ]] || [[ $YN == 'y' ]]
then
	echo 'Great!'
elif [[ $YN == 'N' ]] || [[ $YN == 'n' ]]
then
	echo -e 'Which IP then? Please enter the ip address and subnet mask prefix like this:\nx.x.x.x/x'
	read IPSUB
else
	echo 'Please just type Y or n. Better luck next time. Bye!'
	exit 1
fi
# Cut the given IP and subnet into separate variables.
IP=$(echo $IPSUB | cut -d '/' -f 1) 
SUB=$(echo $IPSUB | cut -d '/' -f 2)
MASKB=()
# Cut the IP address octets into their separate values.
IPCUT=( $(echo $IP | tr '.' ' ') )
IPB=()
BITS=( 128 64 32 16 8 4 2 1 )
BASENETB=()
BASENET=()
WCARD=()
# Determine the available bits for host addresses.
HOSTB=$((32 - $SUB ))
# Calculate maximum available host addresses for the subnet.
MAXHOSTS=$((2 ** $(($HOSTB))  - 3))
echo 'Your IP adress is:' $IP
echo 'Your subnet mask is: /'$SUB
# Turn the decimal subnet prefix into the binary notation.
if [ $SUB > 1 ]
then
	MASKB=$[ 1 ]
	SUB=$[ $SUB - 1 ]
fi
while [ $SUB -gt 0 ] ; do
	MASKB+=( 1 )
	SUB=$[ $SUB - 1 ]
done
while [ ${#MASKB[@]} -lt 32 ] ; do
	MASKB+=( 0 )
done
# Turn the IP address into its binary notation.
for i in ${IPCUT[@]} ; do
	ph=$i
	for j in ${BITS[@]} ; do
		if [ $ph -ge $j ]
		then
			ph=$(($ph - $j)) 
			IPB+=( 1 )
		else
			IPB+=( 0 )
		fi
	done
done
# Compare the binary IP address against the binary subnet
# to determine the binary network address.
for i in ${!IPB[@]} ; do
	if [ ${MASKB[i]} == 1 ]
	then
		BASENETB+=( ${IPB[i]} )
	fi
done
count=0
octet=0
# Turn the binary network address into its decimal notation.
for i in ${BASENETB[@]} ; do
	let octet+=( $i * ${BITS[count]} )
	let count+=1
	if [ $count -eq 8 ]
	then
		BASENET+=( $octet )
		octet=0
		count=0
	fi
done
# Add a 0 to the decimal network to create four octets.
while [ ${#BASENET[@]} != 4 ] ; do
	BASENET+=( 0 )
done
echo 'The maximum amount of host addresses is: '$MAXHOSTS
echo 'The base network is: '${BASENET[0]}.${BASENET[1]}.${BASENET[2]}.${BASENET[3]}
echo 'Scanning hosts...'
# Determine the amount of octets fully filled with network bits.
octets=$(( $HOSTB / 8 ))
# Determine the amount of bits free for host addresses.
lastbits=$(( $HOSTB % 8 ))
count=$octets
octet=$(( ${#BASENET[@]} - 1 ))
curoct=${BASENET[$octet]}
# Copy the network octets into a new array.
WORKNET=()
for i in ${BASENET[@]} ; do
	WORKNET+=( $i )
done
# Ping all possible IP addresses.
while [ $count -gt 0 ] ; do
	until [ $curoct -eq 255 ] ; do
		WORKNET[$octet]=$((  ${WORKNET[$octet]} + 1 ))
		if [ ${WORKNET[3]} == 255 ]
		then
			# Prevent the broadcast address from being included.
			WORKNET[3]=254
		fi
		thisip=${WORKNET[0]}.${WORKNET[1]}.${WORKNET[2]}.${WORKNET[3]}
		# Ping the IP and determine if a package has been received.
		exists=$(ping -c 1 $thisip | grep -c '1 received')
		if [ $exists == 1 ]
		then
			echo $thisip 'exists'
		fi
		let curoct+=1
	done
	let count+=1
done 
