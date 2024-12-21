#!/bin/bash
api=$2

if [ $# -eq 2 ]
then
	curl -H "X-API-Key: $api" https://api.dnsdumpster.com/domain/$1 | jq -r '.a[] | "Subdomain: \(.host), IP: \(.ips[] |.ip), Technologies: \(.ips[] | {banners: .banners, https: .https}),\n"' > output_api.txt

	if [ -f output_api.txt ]
	then
	    cat output_api.txt | awk -F"," '{print $1, $2}' | while IFS= read -r line
   	    do 
	    subdomain=$(echo "$line" | grep '^Subdomain' | grep -oP 'Subdomain: \K[^ ]+') 
	    ip=$(echo "$line" | grep '^Subdomain' | grep -oP 'IP: \K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
	    if ping -c 1 -W 2 "$ip"; then 
		echo "Host $ip is up, performing nmap scan..."
		ports=$(nmap --open -T4 "$ip" | grep "open" | awk '{print $1 ":    " $3}')
	        echo "Host: $subdomain ($ip)" 
	        echo -e "Open Ports:\n$ports" 
	        echo -e "Done.\n\n"
	    fi	
    	    done
	else
	    echo "Something went wrong. Try again."
	fi
else
    echo "It seems the api key or the domain were not provided."
fi

