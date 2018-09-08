#!/bin/bash

#Confirming the EUID as root. Will not be albe to run the script without root permission.
if [[ $EUID -ne 0 ]]; then
		echo ""
        echo "You must be root to run this script."
        echo ""
        exit 1
fi

clear

PS3='Please select an option: '
options=("Clean all iptables/ip6tables files and settings" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Clean all iptables/ip6tables files and settings")
			
            echo "Flushing existing settings..."
            iptables -F
            ip6tables -F
            sleep 1
            echo ""
            echo "Removing files:"
            echo "* /etc/iptables.scriptgenerated.rules"
            echo "* /etc/iptables.final.rules"
            echo "* /etc/network/if-pre-up.d/iptables"
            echo "* /etc/ip6.scriptgenerated.rules"
            echo "* /etc/network/if-pre-up.d/ip6tables"
            
            rm /etc/iptables.scriptgenerated.rules /etc/iptables.final.rules /etc/network/if-pre-up.d/iptables /etc/ip6.scriptgenerated.rules /etc/network/if-pre-up.d/ip6tables

            echo ""
            echo "Done!"

            break
            ;;

        #Exiting the script.
        "Quit")
            break
            ;;

        #All other arguments rather than the options will not be valid. Will loop the script.
        *) echo Invalid argument;;
    esac
done
