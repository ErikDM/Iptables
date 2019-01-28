# Iptables
A bash script which can add and remove iptables rules for a typical "Capture the flag". The user will be prompted to set a subnet range to include within the rules. All other users outside the subnet will be blocked. The user will also be prompted to add the rules persistent, and also if he/she wants to block all ipv6 inbound traffic.

--------------------------------------------------------------------

The rules implemented are:

- TCP connection limit. Will limit the amount of TCP connections to deny connection attacks. Will reject IF above 50 TCP connections.
- Dropping all invalid packets. Will help against (D)DoS attacks.
- Droping all invalid packets with no proper flag request towards the server. Will help against (D)DoS attacks.
- Allows all outbound traffic.
- Allows ping, but denies unregular icmp requests (ping of death and so on).
- Allows HTTP and HTTPS connections from the specific subnet.
- Allows 12 failed SSH connection attempts in 300 seconds, then ban the IP for 300 seconds (5 minutes) if the limit is exceeded. Prevents SSH enumeration and brute force. The limit can be increased/decreased if necessary.
- Accepts all established inbound connections.
- Allows new SSH connections.
- Preventing (D)DoS attacks on the HTTP(S) ports by limiting the amount of connections pr minute.
- Allows all loopback on the specific subnet (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0.
- Drop all: default deny unless explicitly allowed policy


**** TROUBLESHOOTING ****
If you experience error: "/bin/bash^M: bad interpreter: No such file or directory" it is because the script was created in a Windows environment. You can port this over to Unix compatibility by using the following command:
`sed -i -e 's/\r$//' scriptname.sh`
