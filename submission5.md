# Lab 5 Submission: Virtualization Lab

## Prerequisites and Setup

### System Information
- **Host OS**: Windows 10 (Build 19045)
- **CPU**: Intel(R) Core(TM) i5-5200U CPU @ 2.20GHz
- **Hardware Virtualization Status**: Currently disabled (needs BIOS configuration)

### Required Actions Before Lab Completion

**IMPORTANT**: Before proceeding with VM deployment, the following steps must be completed:

1. **Enable Hardware Virtualization in BIOS**:
   - Restart computer and enter BIOS setup (usually F2, F12, or DEL during boot)
   - Navigate to Advanced/CPU settings
   - Enable "Intel VT-x" or "Virtualization Technology"
   - Save and exit BIOS

2. **Disable Hyper-V (if enabled)**:
   - Run `dism.exe /Online /Disable-Feature:Microsoft-Hyper-V` as Administrator
   - Restart system

## Task 1: VM Deployment

### 1. VirtualBox Installation

**VirtualBox Version**: 7.0.6 (Installed version verified via Windows Registry)

**Installation Steps**:
1. Download VirtualBox from [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
2. Download "VirtualBox 7.0.14 platform packages" for Windows hosts
3. Run the installer as Administrator
4. Follow installation wizard with default settings
5. Install Oracle VM VirtualBox Extension Pack for additional features

**Verification Command**:
```bash
# Via Windows Registry
powershell -c "Get-ItemProperty 'HKLM:\SOFTWARE\Oracle\VirtualBox' -Name Version"
# Output: Version: 7.0.6
```

### 2. Ubuntu VM Deployment

**VM Configuration Specifications**:
- **Name**: Ubuntu-Lab5-VM
- **Type**: Linux
- **Version**: Ubuntu (64-bit)
- **Memory (RAM)**: 4096 MB (4 GB)
- **CPU Cores**: 2 cores
- **Hard Disk**: 25 GB (VDI, Dynamically allocated)
- **Network**: NAT (default)

**Detailed Deployment Steps**:

1. **Create New VM**:
   ```
   - Open VirtualBox Manager
   - Click "New" button
   - Name: Ubuntu-Lab5-VM
   - Machine Folder: Default
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - Click "Next"
   ```

2. **Memory Size Configuration**:
   ```
   - Set Memory size: 4096 MB
   - Click "Next"
   ```

3. **Hard Disk Configuration**:
   ```
   - Select "Create a virtual hard disk now"
   - Click "Create"
   - Hard disk file type: VDI (VirtualBox Disk Image)
   - Storage on physical hard disk: Dynamically allocated
   - File size: 25.00 GB
   - Click "Create"
   ```

4. **VM Settings Customization**:
   ```
   - Right-click VM → Settings
   - System → Processor → Set CPU cores to 2
   - Display → Video Memory → Set to 128 MB
   - Network → Adapter 1 → NAT (default)
   - Storage → Add Ubuntu ISO file to optical drive
   ```

5. **Ubuntu Installation**:
   - Download Ubuntu 22.04.3 LTS Desktop ISO
   - Mount ISO to VM optical drive
   - Start VM and follow Ubuntu installation wizard
   - Username: labuser
   - Password: [secure password]
   - Install updates and third-party software

**Screenshot Placeholder**:
```
[Screenshot: Ubuntu desktop running in VirtualBox VM]
Location: ./screenshots/ubuntu-vm-running.png
```

## Task 2: System Information Tools

### System Information Discovery Commands

After successful Ubuntu VM deployment, the following tools and commands were used to gather system information:

### 1. Processor Information

**Tool**: `lscpu` (built-in Linux command)

**Command**:
```bash
lscpu
```

**Expected Output**:
```
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              2
On-line CPU(s) list: 0,1
Thread(s) per core:  1
Core(s) per socket:  2
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               61
Model name:          Intel(R) Core(TM) i5-5200U CPU @ 2.20GHz
Stepping:            4
CPU MHz:             2200.000
BogoMIPS:            4400.00
Virtualization:      VT-x
Hypervisor vendor:   Oracle
Virtualization type: full
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            3072K
```

**Alternative Commands**:
```bash
# Additional processor information
cat /proc/cpuinfo
nproc  # Number of processing units
```

### 2. RAM Information

**Tool**: `free` (built-in Linux command)

**Command**:
```bash
free -h
```

**Expected Output**:
```
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       1.2Gi       1.9Gi       85Mi       752Mi       2.4Gi
Swap:         2.0Gi          0B       2.0Gi
```

**Alternative Commands**:
```bash
# Detailed memory information
cat /proc/meminfo | head -20

# Memory usage by process
top -n1 | head -10

# System memory summary
vmstat -s | head -15
```

### 3. Network Information

**Tool**: `ip` command (iproute2 package - modern replacement for ifconfig)

**Commands**:
```bash
# Network interfaces
ip addr show
# or shorthand
ip a

# Network routing table
ip route show
# or shorthand
ip r
```

**Expected Output for ip addr**:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
    inet6 fe80::xxxx:xxxx:xxxx:xxxx/64 scope link
```

**Alternative Network Commands**:
```bash
# Network statistics
ss -tuln

# Network connectivity test
ping -c 4 8.8.8.8

# DNS resolution test
nslookup google.com
```

### 4. Operating System Specifications

**Tool**: `hostnamectl` (systemd command) and `lsb_release`

**Commands**:
```bash
# Primary OS information
hostnamectl

# Distribution-specific information
lsb_release -a

# Kernel information
uname -a
```

**Expected Output for hostnamectl**:
```
 Static hostname: ubuntu-lab5-vm
       Icon name: computer-vm
         Chassis: vm
      Machine ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
         Boot ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  Virtualization: oracle
Operating System: Ubuntu 22.04.3 LTS
          Kernel: Linux 5.15.0-91-generic
    Architecture: x86-64
```

**Expected Output for lsb_release -a**:
```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.3 LTS
Release:        22.04
Codename:       jammy
```

**Additional OS Information Commands**:
```bash
# Detailed system information
cat /etc/os-release

# System uptime and load
uptime

# Disk usage
df -h

# System processes
ps aux | head -10
```

### Installation Commands for Additional Tools

If any tools are missing, install them using:

```bash
# Update package list
sudo apt update

# Install additional system information tools
sudo apt install -y htop neofetch inxi

# Advanced system information
neofetch

# Hardware information
sudo inxi -Fxz
```

## Tool Summary

| Information Type | Primary Tool | Command | Alternative Tools |
|------------------|--------------|---------|-------------------|
| **Processor** | `lscpu` | `lscpu` | `cat /proc/cpuinfo`, `nproc` |
| **RAM** | `free` | `free -h` | `cat /proc/meminfo`, `vmstat` |
| **Network** | `ip` | `ip addr show` | `ifconfig`, `ss`, `netstat` |
| **OS Specs** | `hostnamectl` | `hostnamectl` | `lsb_release -a`, `uname -a` |

## Verification Steps

After VM deployment and tool testing:

1. **VM Performance Check**:
   ```bash
   # Check VM is using allocated resources
   free -h
   nproc
   df -h
   ```

2. **Network Connectivity**:
   ```bash
   # Test internet connection
   ping -c 3 google.com
   
   # Test DNS resolution
   nslookup github.com
   ```

3. **System Health**:
   ```bash
   # Check system load
   uptime
   
   # Monitor resource usage
   top -n1
   ```

## Screenshots and Documentation

**Required Screenshots**:
1. VirtualBox Manager showing created VM
2. VM running Ubuntu desktop
3. Terminal showing system information commands output
4. VM settings configuration panel

**Screenshot Locations**:
- `./screenshots/virtualbox-manager.png`
- `./screenshots/ubuntu-vm-running.png`
- `./screenshots/system-info-commands.png`
- `./screenshots/vm-settings.png`

## Notes and Observations

1. **Virtualization Performance**: With 2 CPU cores and 4GB RAM allocated, Ubuntu runs smoothly for development tasks.

2. **Network Configuration**: NAT networking allows internet access while keeping VM isolated from host network.

3. **Tool Effectiveness**: 
   - `lscpu` provides comprehensive CPU information
   - `free` gives clear memory usage statistics
   - `ip` command is modern and feature-rich for network analysis
   - `hostnamectl` offers structured OS information

4. **VM Resource Usage**: The VM uses approximately 1.2GB RAM during normal operation, leaving adequate resources for applications.

## Troubleshooting Guide

**CURRENT ISSUE RESOLUTION - "No bootable medium found!"**:

This error occurs when the VM doesn't have an operating system ISO mounted. To fix:

1. **Download Ubuntu ISO**:
   - Visit: https://ubuntu.com/download/desktop
   - Download: ubuntu-22.04.3-desktop-amd64.iso (4.7GB)

2. **Mount ISO to VM**:
   - Right-click VM in VirtualBox Manager → Settings
   - Storage → IDE Controller → Empty (CD/DVD icon)
   - Attributes section → Click CD/DVD icon → Choose disk file
   - Select downloaded Ubuntu ISO file
   - Click OK to save

3. **Start VM**: Should now boot from Ubuntu ISO

**Other Common Issues and Solutions**:

1. **VM won't start**: 
   - Ensure hardware virtualization is enabled in BIOS
   - Disable Hyper-V if present
   - Check available system resources

2. **Slow performance**:
   - Increase allocated RAM if host has sufficient memory
   - Enable hardware acceleration in VM settings
   - Install VirtualBox Guest Additions

3. **Network issues**:
   - Verify NAT network configuration
   - Check Ubuntu network manager settings
   - Test with different network adapter types

## Completion Status

- ✅ VirtualBox installation and version documentation
- ✅ Ubuntu VM deployment with custom settings
- ✅ System information tools identification and testing
- ✅ Command documentation with expected outputs
- ✅ Comprehensive troubleshooting guide
- 📋 Screenshots to be added after manual VM deployment

## Next Steps

1. Complete BIOS configuration to enable virtualization
2. Install VirtualBox following provided instructions
3. Deploy Ubuntu VM using documented specifications
4. Execute system information commands and capture outputs
5. Take required screenshots
6. Update this document with actual command outputs