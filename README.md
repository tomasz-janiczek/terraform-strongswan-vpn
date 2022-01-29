strongSwan based site-to-site VPN
=================================

# Testing
## Fire an automated test to see if the connection is up and running
1. Prepare the IP address of a host in the target network that you want to reach via the VPN
2. Run the script `test.sh <host-IP-address>`

## Manually test to see if the connection is up and running

The testing process - checking if the tunnel is up and the other network is available - is a very simple one.
As strongSwan is a set of tools utilizing the Linux kernel IPSec implementation, it's all about using the standard Linux tools to find the root cause of the problem.

So you'll be using:
* tcpdump
* syslog files
* the *ip* command
* the *ipsec* command
* the *sysctl* command

### Testing process:
1. Start the strongSwan VPN EC2 instance
2. SSH into the strongSwan instance
3. Check if the tunnel is up by issuing the command *ipsec statusall* and looking for messages stating that the tunnel is *ESTABLISHED* and that there are at least one *Security Associations*
4. If not, issue the command *ipsec restart* and check again in a few seconds
5. Try to ping the other side of the tunnel from the instance
6. If you got a response - it's done!
7. If you didn't - check the logs by examining the file /var/log/syslog and looking for entries put there by the ***charon*** daemon
8. Fix the issues you have found (both https://wiki.strongswan.org and StackOverflow are your friends...) and try again

#### Hints
* IMPORTANT: having a tunnel established according to the ipsec command (see up) DOES NOT MEAN YOU HAVE A PROPERLY WORKING VPN! One can have a tunnel established but with no data flowing through it. BEWARE!
* if you can't establish a tunnel according to *ipsec statusall*, you are having a mismatch in the parameters of the tunnel (IPs, CIDRs, encryption algorithms, left and right side IDs etc.). Double and triple check them - there is a mismatch somewhere, you just have to find it
* to check if data is going out AND COMING IN you will need to fire up the command *tcpdump esp* and start pinging a host from the destination network to  check for ESP packets going both ways (this is important).
* NOTE: you won't see any ESP packets if you are using NAT-T (ESP in UDP)
* if you have a tunnel established and ESP packets flowing and still can't reach the other side, it most probably is a routing issue - check all the needed routing tables on both sides (on your side - both the one on the strongSwan instance and in the AWS VPC/subnets)

# Local setup
## Set up your local machine as an VPN endpoint
1. Copy the file ansible/local-vpn-endpoint.yml.dist to ansible/local-vpn-endpoint.yml
2. Edit the file and put valid VPN configuration inside
3. Run the command `task install-local-vpn`
