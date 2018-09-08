#!/bin/bash

#This is a script which will add a set of IP tables rules, and then ask the user to make them persistent.

#Confirming the EUID as root. Will not be albe to run the script without root permission.
if [[ $EUID -ne 0 ]]; then
		echo ""
        echo "You must be root to run this script."
        echo ""
        exit 1
fi

clear

echo ""
echo "Adding rules to location: /etc/iptables.scriptgenerated.rules"
echo "Please go into the configuration file and comment out the settings which does not apply to you."
echo ""

#Echo'ing the rules into the file /etc/iptables.scriptgenerated.rules
echo "*filter" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "-A INPUT -i lo -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT" >> /etc/iptables.scriptgenerated.rules

echo "#Will limit the amount of TCP connections towards the server. Will reject IF above 100 TCP connections. Can be increased if necessary." >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp -m connlimit --connlimit-above 100 -j REJECT --reject-with tcp-reset" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "# Drop all invalid packets" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -m state --state INVALID -j DROP" >> /etc/iptables.scriptgenerated.rules
echo "-A FORWARD -m state --state INVALID -j DROP" >> /etc/iptables.scriptgenerated.rules
echo "-A OUTPUT -m state --state INVALID -j DROP" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "-A INPUT -p tcp ! --syn -m state --state NEW -j DROP" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp --tcp-flags ALL NONE -j DROP" >> /etc/iptables.scriptgenerated.rules

echo "# Accepts all established inbound connections" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "# Allows all outbound traffic" >> /etc/iptables.scriptgenerated.rules
echo "#This must be enabled for people to run exploits and using reverse shells. We do not know the reverse ports" >> /etc/iptables.scriptgenerated.rules
echo "-A OUTPUT -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "# Allows HTTP and HTTPS connections from anywhere" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp --dport 80 -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp --dport 443 -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "#Allows 12 failed SSH connection attempts in 300 seconds, then ban the IP for 300 seconds (5 minutes) if the limit is exceeded." >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 12 --name DEFAULT --rsource -j DROP" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "# Allows new SSH connections" >> /etc/iptables.scriptgenerated.rules
echo "# The --dport number is the same as in /etc/ssh/sshd_config" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "#Allow ping" >> /etc/iptables.scriptgenerated.rules
echo "#Note that blocking other types of icmp packets can be a problem during troubleshooting by the crew." >> /etc/iptables.scriptgenerated.rules
echo "#Remove -m icmp --icmp-type 8 from this line to allow all kinds of icmp:" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "#Reject all other inbound - default deny unless explicitly allowed policy:" >> /etc/iptables.scriptgenerated.rules
echo "-A INPUT -j REJECT" >> /etc/iptables.scriptgenerated.rules
echo "-A FORWARD -j REJECT" >> /etc/iptables.scriptgenerated.rules
echo "" >> /etc/iptables.scriptgenerated.rules

echo "COMMIT" >> /etc/iptables.scriptgenerated.rules

iptables-restore < /etc/iptables.scriptgenerated.rules

echo "Following rules has been added to: /etc/iptables.scriptgenerated.rules"
echo ""
iptables -L
echo ""

#Prompting the user for a Y/N answer if the new rules should be persistent or not.
printf "Do you want to make these rules persistent? <Y/N>: "
read -r answer1
if [[ $answer1 == "y" || $answer1 == "Y" ]]; then
	iptables-save > /etc/iptables.final.rules
	echo "#!/bin/sh" >> /etc/network/if-pre-up.d/iptables
	echo "/sbin/iptables-restore < /etc/iptables.final.rules" >> /etc/network/if-pre-up.d/iptables
	chmod 750 /etc/network/if-pre-up.d/iptables
	echo ""
	echo "Done! The persistent file is located at etc/network/if-pre-up.d/iptables with the permissions <750>"
	echo ""
else
echo "The rules were not added persistent."
echo ""
fi

#Prompting the user for a Y/N answer if the user wants to block all incoming IPv6 traffic.
printf "Do you want to block all INPUT IPv6 traffic (using ip6tables) <Y/N>: "
read -r answer2
if [[ $answer2 == "y" || $answer2 == "Y" ]]; then
	ip6tables -P INPUT DROP
	echo "Done."
	#Prompting the user for a Y/N answer if the new rules should be persistent or not.
	printf "Do you want to make the ip6tables rules persistent? <Y/N>: "
	read -r answer3
	if [[ $answer3 == "y" || $answer3 == "Y" ]]; then
		echo "Putting rules into /etc/ip6.scriptgenerated.rules"
		echo "ip6tables -P INPUT DROP" >> /etc/ip6.scriptgenerated.rules
		ip6tables-save > /etc/ip6.scriptgenerated.rules
		echo "#!/bin/sh" >> /etc/network/if-pre-up.d/ip6tables
		echo "/sbin/ip6tables-restore < /etc/ip6.scriptgenerated.rules" >> /etc/network/if-pre-up.d/ip6tables
		chmod 750 /etc/network/if-pre-up.d/ip6tables
		echo "Done! The persistent file is located at etc/network/if-pre-up.d/ip6tables with the permissions <750>"
		exit 1
	else
		echo "The IPv6 rules were not added persistent."
		exit 1
	fi
else
echo "Exiting."
fi
