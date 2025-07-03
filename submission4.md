# Lab 4 Submission: Operating Systems & Networking Analysis

## Task 1: Operating System Analysis

### 1.1: Boot Performance

**System Boot Time Analysis:**
```
$ wmic os get lastbootuptime
LastBootUpTime
20250626192618.564860+180  

$ systeminfo | findstr "Boot Time"
System Boot Time:          6/26/2025, 7:26:18 PM
Boot Device:               \Device\HarddiskVolume1
Time Zone:                 (UTC+03:00) Moscow, St. Petersburg
```

**Key Observations:**
- System boot time: June 26, 2025, 7:26:18 PM (UTC+3)
- Boot device: Primary hard disk volume 1
- The system has been running since the last boot time

### 1.2: Process Forensics

**Resource-Intensive Processes (Top Memory Consumers):**

From the process analysis, the top memory-consuming processes are:

1. **chrome.exe (PID 13824)**: 656,711,680 bytes (~629 MB) - Highest memory usage
2. **chrome.exe (PID 19472)**: 562,155,520 bytes (~536 MB) - Browser tab
3. **chrome.exe (PID 4456)**: 430,485,504 bytes (~411 MB) - Main browser process

**Key Observations:**
- Google Chrome browser processes consume the most system memory
- Multiple Chrome processes indicate active browsing with multiple tabs
- Memory usage shows a typical development environment with browser and IDE

### 1.3: Service Dependencies

**Windows Services Status Summary:**

Key running services include:
- **Core System Services**: 
  - services.exe (PID 932): Windows Service Control Manager
  - lsass.exe (PID 956): Local Security Authority
  - svchost.exe (multiple instances): Generic Service Host processes

- **Security Services**:
  - WinDefend: Windows Defender running (PID 6008)
  - MsMpEng.exe: Microsoft Malware Protection Engine

- **Network Services**:
  - Dhcp: DHCP Client service
  - NlaSvc: Network Location Awareness
  - WlanSvc: WLAN AutoConfig

**Key Observations:**
- System has essential security services running
- Network connectivity services are active
- Multiple svchost.exe processes manage different service groups

### 1.4: User Sessions

**Login Activity:**
```
$ query user
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
>mahmoud mousatat      console             1  Active      none   6/26/2025 7:26 PM
```

**Key Observations:**
- Single user currently logged in: "mahmoud mousatat"
- Session type: Console (local login)
- Session state: Active with no idle time
- Login time matches system boot time, indicating login at startup

### 1.5: Memory Analysis

**System Memory Information:**
```
$ wmic OS get TotalVirtualMemorySize,TotalVisibleMemorySize,FreePhysicalMemory
FreePhysicalMemory  TotalVirtualMemorySize  TotalVisibleMemorySize  
2609936             23636224                12490552
```

**Memory Analysis (in KB):**
- **Total Physical Memory**: 12,490,552 KB (~12.2 GB)
- **Free Physical Memory**: 2,609,936 KB (~2.5 GB)
- **Total Virtual Memory**: 23,636,224 KB (~23.1 GB)
- **Memory Utilization**: ~79% of physical memory in use

**Key Observations:**
- System has adequate physical memory (12.2 GB)
- High memory utilization due to development tools and browser usage
- Virtual memory provides additional capacity for large applications

## Task 2: Networking Analysis

### 2.1: Network Path Tracing

**Traceroute to github.com:**
```
Tracing route to github.com [140.82.121.4]
over a maximum of 30 hops:

  1    14 ms    13 ms     1 ms  10.248.1.1 
  2     2 ms     2 ms     2 ms  10.250.0.2 
  3     3 ms    14 ms     2 ms  10.252.6.1 
  4    20 ms     5 ms     4 ms  188.170.164.34 
  5     *        *        *     Request timed out.
  6     *        *        *     Request timed out.
  7     *        *        *     Request timed out.
  8     *        *        *     Request timed out.
  9    42 ms    44 ms    44 ms  83.169.204.82 
 10    43 ms    46 ms    48 ms  netnod-ix-ge-a-sth-1500.inter.link [194.68.123.180] 
 11    60 ms    59 ms    65 ms  r1-cph1-dk.as5405.net [94.103.180.38] 
 18    68 ms    61 ms    64 ms  r1-fra3-de.as5405.net [94.103.180.24] 
 19    63 ms    58 ms    71 ms  cust-sid435.r1-fra3-de.as5405.net [45.153.82.39] 
 22    59 ms    59 ms    59 ms  lb-140-82-121-4-fra.github.com [140.82.121.4] 
```

**DNS Resolution Check:**
```
$ nslookup github.com
Server:  UnKnown
Address:  10.90.137.30

Name:    github.com
Address:  140.82.121.4
```

**Key Observations:**
- Total route hops to GitHub: 22 hops
- Local network gateway: 10.248.1.1
- Route passes through Stockholm (netnod-ix), Copenhagen (cph1-dk), and Frankfurt (fra3-de)
- Final destination: GitHub's Frankfurt load balancer (140.82.121.4)
- Some intermediate hops timeout, likely due to firewall configurations

### 2.2: DNS Traffic Analysis

**DNS-Related Network Connections:**
```
$ netstat -an | findstr :53
  TCP    10.248.1.78:60433      10.90.137.30:53        TIME_WAIT  
  UDP    0.0.0.0:53             *:*
  UDP    0.0.0.0:5353           *:*
  UDP    0.0.0.0:5355           *:*
  UDP    10.248.1.78:5353       *:*
  UDP    127.0.0.1:53179        *:*
```

**Example DNS Query Pattern:**
- DNS server: 10.90.137.30 (port 53)
- Local machine: 10.248.1.78
- Connection state: TIME_WAIT (recently completed DNS query)
- Multiple mDNS (port 5353) listeners for local network discovery

### 2.3: Reverse DNS Lookups

**PTR Lookup for 8.8.4.4:**
```
$ nslookup 8.8.4.4
Server:  UnKnown
Address:  10.90.137.30

Name:    dns.google
Address:  8.8.4.4
```

**PTR Lookup for 1.1.2.2:**
```
$ nslookup 1.1.2.2
Server:  UnKnown
Address:  10.90.137.30

*** UnKnown can't find 1.1.2.2: Non-existent domain
```

**Key Observations:**
- 8.8.4.4 successfully resolves to "dns.google" - Google's public DNS server
- 1.1.2.2 has no reverse DNS record (non-existent domain)
- Local DNS server (10.90.137.30) handles both forward and reverse lookups

## Summary Analysis

### Operating System Health
- System shows healthy resource utilization with 12.2 GB RAM
- Development environment with Chrome browser consuming most memory
- Essential system services running properly
- Single active user session since boot

### Network Connectivity
- Internet connectivity through multi-hop routing via European infrastructure
- DNS resolution working properly through local DNS server
- Route optimization through major internet exchange points
- Some network security measures evident (filtered hops in traceroute)

### Security Observations
- Windows Defender actively running
- Proper service isolation through multiple svchost processes
- Network security filtering evident in traceroute timeouts
- DNS services properly configured for internal and external resolution

**IP Sanitization Note**: All external IP addresses in packet captures have been documented as-is since they represent public infrastructure. Internal network IPs (10.248.x.x range) are part of the analysis scope.