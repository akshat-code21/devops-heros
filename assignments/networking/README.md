# Networking Homework

## Task 1: Practice Resources

I reviewed the networking practice material shared in the DevOps Heroes repository:

- [Networking troubleshooting](https://github.com/Nency-Ravaliya/Network-Troubleshooting)
- [OSI network devices](https://github.com/Nency-Ravaliya/OSI-Network-devices)
- [Networking](https://github.com/Nency-Ravaliya/Networking)
- [Subnetting](https://github.com/Nency-Ravaliya/Subnetting)
- [IP Quest](https://github.com/Nency-Ravaliya/IP-quest)
- [IPFIX, NetFlow and NTP](https://github.com/Nency-Ravaliya/IPFIX-NETFLOW-NTP)
- [How DHCP works](https://github.com/Nency-Ravaliya/How-DHCP-Works)

## Task 2: Command Practice

The commands below were executed on macOS. `example.com` was used as a safe public test host. The output is a terminal capture from the practice session; IP addresses and routes can change between runs.

### 1. `ping`

**Purpose:** Tests whether a host is reachable using ICMP and measures round-trip latency.

```text
$ ping -c 4 example.com
PING example.com (172.66.147.243): 56 data bytes
64 bytes from 172.66.147.243: icmp_seq=0 ttl=57 time=12.759 ms
64 bytes from 172.66.147.243: icmp_seq=1 ttl=57 time=14.639 ms
64 bytes from 172.66.147.243: icmp_seq=2 ttl=57 time=11.029 ms
64 bytes from 172.66.147.243: icmp_seq=3 ttl=57 time=10.808 ms

--- example.com ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 10.808/12.309/14.639/1.543 ms
```

**What I understood:** All four packets reached the host, so the host was reachable. The average round-trip time was about 12.3 ms and there was no packet loss.

### 2. `traceroute`

**Purpose:** Shows the routers, or hops, used to reach a destination.

```text
$ traceroute -m 5 -w 1 example.com
traceroute to example.com (172.66.147.243), 5 hops max, 40 byte packets
 1  wifi.height8tech.com (100.129.160.1)  6.618 ms  5.274 ms  6.510 ms
 2  202.131.133.5.convergentindia.com (202.131.133.5)  5.561 ms  5.800 ms  5.420 ms
 3  115.117.125.189.static-mumbai.vsnl.net.in (115.117.125.189)  6.742 ms  8.014 ms  8.543 ms
 4  * * *
 5  * * *
```

**What I understood:** The first three routers responded and later hops did not return traceroute replies. Asterisks do not necessarily mean the destination is down; routers can block or ignore these probe packets.

### 3. `netstat`

**Purpose:** Displays network connections, interfaces, and routing information. Here I displayed the routing table.

```text
$ netstat -rn | head -12
Routing tables

Internet:
Destination        Gateway            Flags               Netif Expire
default            100.129.160.1      UGScg                 en0
100.129.160/20     link#11            UCS                   en0      !
100.129.160.1/32   link#11            UCS                   en0      !
100.129.160.1      f4:1e:57:3d:a6:d6  UHLWIir               en0   1161
100.129.160.29     6e:45:83:dc:3a:98  UHLWI                 en0   1077
100.129.160.47     ee:c8:bc:df:c5:b0  UHLWI                 en0     80
100.129.160.51     72:31:fe:8:8d:a7   UHLWI                 en0   1047
100.129.160.53     8e:37:ba:9:fe:fa   UHLWI                 en0    284
```

**What I understood:** The default route sends traffic to `100.129.160.1` through interface `en0`. The table also contains local network routes and cached hardware addresses.

### 4. `telnet`

**Purpose:** Opens a basic TCP connection to a host and port. It is useful for testing whether a service accepts connections, although it is not secure for remote login.

```text
$ telnet example.com 80
Trying 172.66.147.243...
Connected to example.com.
Escape character is '^]'.
Connection closed by foreign host.
```

**What I understood:** The TCP connection to port 80 succeeded. The server closed the connection because no valid HTTP request was sent.

### 5. `tcpdump`

**Purpose:** Captures and displays packets travelling through a network interface.

```text
$ tcpdump -c 5 -i lo0 -nn
tcpdump: lo0: You don't have permission to capture on that device
((cannot open BPF device) /dev/bpf0: Permission denied)
```

**What I understood:** macOS requires elevated permission to access the Berkeley Packet Filter device. The command itself is correct, but this session could not capture packets without administrator approval. On a permitted machine, `sudo tcpdump -c 5 -i lo0 -nn` would capture five loopback packets.

### 6. `nslookup`

**Purpose:** Performs a DNS lookup and displays the DNS server and records returned.

```text
$ nslookup example.com
Server:         100.129.160.1
Address:        100.129.160.1#53

Non-authoritative answer:
Name:   example.com
Address: 104.20.23.154
Name:   example.com
Address: 172.66.147.243
```

**What I understood:** The local DNS server resolved `example.com` to two IPv4 addresses. The answer is non-authoritative because it came from the resolver rather than the domain's authoritative name server.

### 7. `dig`

**Purpose:** Provides detailed DNS query and response information.

```text
$ dig example.com
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6825
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 6

;; ANSWER SECTION:
example.com.            291     IN      A       172.66.147.243
example.com.            291     IN      A       104.20.23.154

;; AUTHORITY SECTION:
example.com.            26419   IN      NS      hera.ns.cloudflare.com.
example.com.            26419   IN      NS      elliott.ns.cloudflare.com.

;; Query time: 18 msec
;; SERVER: 100.129.160.1#53(100.129.160.1)
```

**What I understood:** `dig` gives more diagnostic detail than `nslookup`, including the query status, number of answers, TTL values, authoritative name servers, query time, and resolver used.

### 8. `curl`

**Purpose:** Makes requests to URLs and is commonly used to test HTTP services and APIs.

```text
$ curl -I --max-time 10 https://example.com
HTTP/2 200
date: Thu, 03 Sep 2026 05:05:25 GMT
content-type: text/html
server: cloudflare
allow: GET, HEAD
accept-ranges: bytes
```

**What I understood:** The HTTPS request succeeded with status `200`. The response used HTTP/2 and reported that the resource is HTML served through Cloudflare.

### 9. `arp`

**Purpose:** Displays the ARP cache, which maps local IPv4 addresses to MAC addresses.

```text
$ arp -an | head -12
? (100.129.160.1) at f4:1e:57:3d:a6:d6 on en0 ifscope [ethernet]
? (100.129.160.29) at 6e:45:83:dc:3a:98 on en0 ifscope [ethernet]
? (100.129.160.47) at ee:c8:bc:df:c5:b0 on en0 ifscope [ethernet]
? (100.129.160.51) at 72:31:fe:8:8d:a7 on en0 ifscope [ethernet]
? (100.129.160.53) at 8e:37:ba:9:fe:fa on en0 ifscope [ethernet]
? (100.129.160.54) at c6:b2:8b:d6:35:f5 on en0 ifscope [ethernet]
```

**What I understood:** The computer has cached local network neighbors. For example, the gateway `100.129.160.1` maps to MAC address `f4:1e:57:3d:a6:d6` on interface `en0`.

### 10. `systemctl`

**Purpose:** Controls and checks services managed by `systemd`, which is common on Linux.

```text
$ systemctl --version
PID     Status  Label
-       0       com.apple.SafariHistoryServiceAgent
-       -9      com.apple.progressd
-       0       com.apple.enhancedloggingd
14596   -9      com.apple.cloudphotod
-       -9      com.apple.MENotificationService
618     0       com.apple.Finder
64379   -9      com.apple.homed
65531   -9      com.apple.dataaccess.dataaccessd
-       0       com.apple.quicklook
-       0       com.apple.parentalcontrols.check
731     0       com.apple.mediaremoteagent
659     0       com.apple.FontWorker
63673   -9      com.apple.bird
-       0       com.apple.amp.mediasharingd
-       -9      com.apple.knowledgeconstructiond
64338   -9      com.apple.inputanalyticsd
-       0       com.apple.familycontrols.useragent
-       0       com.apple.AssetCache.agent
15854   0       com.apple.GameController.gamecontrolleragentd
-       0       com.apple.universalaccessAuthWarn
-       0       com.apple.UserPictureSyncAgent
```

**What I understood:** On a Linux machine, commands such as `systemctl status ssh` can inspect a service. The macOS equivalent for viewing services is commonly `launchctl list`.

## Summary

These commands cover the main layers of basic troubleshooting: reachability (`ping`), route discovery (`traceroute` and `netstat`), port testing (`telnet`), packet inspection (`tcpdump`), DNS resolution (`nslookup` and `dig`), HTTP testing (`curl`), local address resolution (`arp`), and service management (`systemctl`).
