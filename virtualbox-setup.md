# VirtualBox Setup for Lab 5

## Installation 

### Step 1: System Preparation

1. **Check System Requirements**:
   - Windows 10/11 (64-bit)
   - At least 4GB RAM (8GB recommended)
   - 30GB free disk space
   - Hardware virtualization support

2. **Enable Virtualization in BIOS**:
   ```
   - Restart computer
   - Press F2/F12/DEL during boot to enter BIOS
   - Navigate to Advanced → CPU Configuration
   - Enable "Intel VT-x" or "Intel Virtualization Technology"
   - Save and Exit (F10)
   ```

3. **Disable Hyper-V (Windows 10/11)**:
   ```cmd
   # Run as Administrator
   dism.exe /Online /Disable-Feature:Microsoft-Hyper-V-All
   # Restart required
   ```

### Step 2: VirtualBox Installation

1. **Download VirtualBox**:
   - Visit: https://www.virtualbox.org/wiki/Downloads
   - Download "Windows hosts" installer
   - Current version: 7.0.14

2. **Install VirtualBox**:
   ```
   - Run VirtualBox-7.0.14-161095-Win.exe as Administrator
   - Accept license agreement
   - Choose installation location (default recommended)
   - Select features to install (keep all selected)
   - Install Oracle Corporation Universal Serial Bus controller (recommended)
   - Complete installation
   ```

3. **Install Extension Pack**:
   ```
   - Download Oracle VM VirtualBox Extension Pack
   - Double-click to install or install via VirtualBox → File → Preferences → Extensions
   - Accept license agreement
   ```

### Step 3: Ubuntu ISO Download

1. **Download Ubuntu 22.04.3 LTS**:
   - Visit: https://ubuntu.com/download/desktop
   - Download ubuntu-22.04.3-desktop-amd64.iso
   - File size: ~4.7GB

### Step 4: VM Creation Script

**VirtualBox Commands for VM Creation**:
```cmd
# Set VM name and folder
set VM_NAME=Ubuntu-Lab5-VM
set VM_FOLDER=%USERPROFILE%\VirtualBox VMs

# Create VM
VBoxManage createvm --name "%VM_NAME%" --ostype "Ubuntu_64" --register

# Configure memory and CPU
VBoxManage modifyvm "%VM_NAME%" --memory 4096 --cpus 2

# Create and attach hard disk
VBoxManage createhd --filename "%VM_FOLDER%\%VM_NAME%\%VM_NAME%.vdi" --size 25600
VBoxManage storagectl "%VM_NAME%" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "%VM_NAME%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%VM_FOLDER%\%VM_NAME%\%VM_NAME%.vdi"

# Configure network
VBoxManage modifyvm "%VM_NAME%" --nic1 nat

# Configure display
VBoxManage modifyvm "%VM_NAME%" --vram 128

# Add IDE controller for DVD
VBoxManage storagectl "%VM_NAME%" --name "IDE Controller" --add ide
```

### Step 5: Verification Commands

**After Installation**:
```cmd
# Check VirtualBox version
VBoxManage --version

# List VMs
VBoxManage list vms

# Check VM details
VBoxManage showvminfo "Ubuntu-Lab5-VM"
```

### Step 6: Ubuntu Installation in VM

1. **Mount Ubuntu ISO**:
   ```
   - Right-click VM → Settings
   - Storage → IDE Controller → Empty
   - Click CD icon → Choose disk file
   - Select ubuntu-22.04.3-desktop-amd64.iso
   ```

2. **Start VM and Install Ubuntu**:
   ```
   - Click Start button
   - Choose "Install Ubuntu"
   - Language: English
   - Keyboard: Default
   - Updates: Install updates during installation
   - Installation type: Erase disk and install Ubuntu
   - User: labuser
   - Password: [secure password]
   - Computer name: ubuntu-lab5-vm
   ```

### Troubleshooting Common Issues

**Issue 1: VM won't start - VT-x is disabled**
```
Solution:
1. Restart computer
2. Enter BIOS (F2/F12/DEL)
3. Enable Intel VT-x
4. Save and exit
```

**Issue 2: Hyper-V conflict**
```
Solution:
1. Open Command Prompt as Administrator
2. Run: bcdedit /set hypervisorlaunchtype off
3. Restart computer
```

**Issue 3: Slow VM performance**
```
Solutions:
1. Increase VM memory to 6GB if host has 12GB+
2. Enable hardware acceleration in VM settings
3. Install VirtualBox Guest Additions in Ubuntu
```

**Issue 4: No internet in VM**
```
Solutions:
1. Check NAT network configuration
2. Reset network adapter in VM settings
3. Restart VM
```

### Post-Installation Tasks

1. **Install VirtualBox Guest Additions**:
   ```bash
   # In Ubuntu VM
   sudo apt update
   sudo apt install build-essential dkms linux-headers-$(uname -r)
   
   # Insert Guest Additions CD image
   # Devices → Insert Guest Additions CD Image
   # Follow installation prompts
   ```

2. **Take VM Snapshot**:
   ```
   - VM → Machine → Take Snapshot
   - Name: "Fresh Ubuntu Installation"
   ```

3. **Configure Shared Folders** (optional):
   ```
   - VM Settings → Shared Folders
   - Add shared folder path from host
   - Enable auto-mount
   ```

### Security Considerations

1. **VM Isolation**: VMs are isolated from host by default
2. **Snapshots**: Regular snapshots for easy recovery
3. **Network Security**: NAT provides basic firewall protection
4. **Updates**: Keep both VirtualBox and Ubuntu updated

### Resource Monitoring

**Host System Monitoring**:
```cmd
# Check available memory
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory

# Monitor CPU usage
wmic cpu get loadpercentage /value
```

**VM Resource Usage**:
```bash
# Inside Ubuntu VM
free -h          # Memory usage
top              # CPU and process monitoring
df -h            # Disk usage
```

This guide provides everything needed to successfully complete Lab 5 virtualization tasks.