# GitOps Fundamentals Lab - Submission

## Overview
This lab demonstrates core GitOps principles through practical Linux command-line simulations:
- **Declarative configuration management**
- **Automated reconciliation**
- **Self-healing systems**
- **State synchronization health monitoring**

## Task 1: Git State Reconciliation

### Objective
Simulate how GitOps operators continuously synchronize cluster state with Git repository.

### Commands Executed

#### 1. Initialize Repository
```bash
mkdir gitops-lab && cd gitops-lab
git init
```

#### 2. Create Desired State
```bash
echo "version: 1.0" > desired-state.txt
git add . && git commit -m "Initial state"
```

#### 3. Simulate Live Cluster
```bash
cp desired-state.txt current-state.txt
```

#### 4. Create Reconciliation Script
```bash
#!/bin/bash
# reconcile.sh
DESIRED=$(cat desired-state.txt)
CURRENT=$(cat current-state.txt)

if [ "$DESIRED" != "$CURRENT" ]; then
echo "$(date) - DRIFT DETECTED! Reconciling..."
cp desired-state.txt current-state.txt
fi
```

#### 5. Trigger Manual Drift
```bash
echo "version: 2.0" > current-state.txt # Simulate manual cluster change
```

#### 6. Run Reconciliation
```bash
chmod +x reconcile.sh
./reconcile.sh # Should detect and fix drift
```

### Task 1 Output

#### Repository Initialization
```bash
$ mkdir -p gitops-lab && cd gitops-lab && git init
Initialized empty Git repository in C:/Users/mahmoud mousatat/Desktop/MASTER/devops/gitops-lab/.git/
```

#### Initial State Commit
```bash
$ echo "version: 1.0" > desired-state.txt && git add . && git commit -m "Initial state"
warning: LF will be replaced by CRLF in desired-state.txt.
The file will have its original line endings in your working directory
[master (root-commit) e52f53f] Initial state
 1 file changed, 1 insertion(+)
 create mode 100644 desired-state.txt
```

#### Drift Detection and Reconciliation
```bash
$ echo "version: 2.0" > current-state.txt # Simulate manual drift
$ ./reconcile.sh
Wed, Jul 16, 2025  7:21:32 AM - DRIFT DETECTED! Reconciling...
```

#### Verification of Reconciliation
```bash
$ cat current-state.txt && echo "---" && cat desired-state.txt
version: 1.0
---
version: 1.0
```

**Result**: The reconciliation script successfully detected the drift (version 2.0 vs 1.0) and automatically restored the current state to match the desired state.

### GitOps Concepts Demonstrated
- **Continuous Reconciliation**: The script continuously monitors for differences between desired and current state
- **Drift Detection**: Automatically identifies when the current state deviates from the desired state
- **Self-Healing**: Automatically corrects configuration drift without manual intervention
- **Declarative Configuration**: The desired state is declared in git, not imperatively commanded

---

## Task 2: GitOps Health Monitoring

### Objective
Implement health checks for configuration synchronization to validate system state consistency.

### Commands Executed

#### 1. Create Health Check Script
```bash
#!/bin/bash
# healthcheck.sh
DESIRED_MD5=$(md5sum desired-state.txt | awk '{print $1}')
CURRENT_MD5=$(md5sum current-state.txt | awk '{print $1}')

if [ "$DESIRED_MD5" != "$CURRENT_MD5" ]; then
echo "$(date) - CRITICAL: State mismatch!" >> health.log
else
echo "$(date) - OK: States synchronized" >> health.log
fi
```

#### 2. Make Executable
```bash
chmod +x healthcheck.sh
```

#### 3. Simulate Healthy State
```bash
./healthcheck.sh
cat health.log# Should show "OK"
```

#### 4. Create Drift
```bash
echo "unapproved change" >> current-state.txt
```

#### 5. Run Health Check
```bash
./healthcheck.sh
cat health.log# Now shows "CRITICAL"
```

### Task 2 Output

#### Initial Health Check (Healthy State)
```bash
$ ./healthcheck.sh && cat health.log
Wed, Jul 16, 2025  7:22:05 AM - OK: States synchronized
```

#### Drift Introduction
```bash
$ echo "unapproved change" >> current-state.txt && cat current-state.txt
version: 1.0
unapproved change
```

#### Health Check After Drift
```bash
$ ./healthcheck.sh && cat health.log
Wed, Jul 16, 2025  7:22:05 AM - OK: States synchronized  
Wed, Jul 16, 2025  7:22:43 AM - CRITICAL: State mismatch!
```

#### Reconciliation and Final Health Check
```bash
$ ./reconcile.sh && cat current-state.txt
Wed, Jul 16, 2025  7:22:52 AM - DRIFT DETECTED! Reconciling...
version: 1.0

$ ./healthcheck.sh && cat health.log
Wed, Jul 16, 2025  7:22:05 AM - OK: States synchronized  
Wed, Jul 16, 2025  7:22:43 AM - CRITICAL: State mismatch!
Wed, Jul 16, 2025  7:23:01 AM - OK: States synchronized
```

**Result**: The health monitoring system successfully:
1. Detected healthy state when files matched (OK status)
2. Identified state mismatch when unauthorized changes were made (CRITICAL status)
3. Confirmed restoration to healthy state after reconciliation (OK status)

The MD5 checksum comparison provides reliable detection of any configuration drift.

### Health Monitoring Concepts
- **State Validation**: Using MD5 checksums to verify configuration integrity
- **Proactive Monitoring**: Detecting issues before they cause system failures
- **Audit Trail**: Logging all state changes for compliance and debugging
- **Health Status**: Clear indicators of system health (OK/CRITICAL)

---

## GitOps Principles Summary

| Task | GitOps Principle | Real-World Equivalent |
|------|------------------|------------------------|
| 1 | Continuous Reconciliation | Argo CD/Flux sync loops |
| 2 | Health Monitoring | Kubernetes operator status checks |

### Key Learnings
1. **Declarative > Imperative**: Configuration should be declared in git, not commanded
2. **Automation Prevents Drift**: Continuous reconciliation prevents configuration drift
3. **Health Monitoring**: Proactive monitoring detects issues before failures
4. **Self-Healing**: Systems should automatically correct deviations from desired state

### Real-World Applications
- **Kubernetes**: GitOps operators like Argo CD and Flux
- **Infrastructure**: Terraform with GitOps workflows
- **CI/CD**: Automated deployment pipelines
- **Configuration Management**: Ansible, Puppet, Chef with git-based workflows

---

## Files Created

The following files were created during the lab execution:

```bash
$ ls -la
total 13
drwxr-xr-x 1 mahmoud mousatat 197121   0 Jul 16 07:22 .
drwxr-xr-x 1 mahmoud mousatat 197121   0 Jul 16 07:20 ..
drwxr-xr-x 1 mahmoud mousatat 197121   0 Jul 16 07:20 .git
-rw-r--r-- 1 mahmoud mousatat 197121  13 Jul 16 07:22 current-state.txt
-rw-r--r-- 1 mahmoud mousatat 197121  13 Jul 16 07:20 desired-state.txt
-rw-r--r-- 1 mahmoud mousatat 197121 170 Jul 16 07:23 health.log
-rwxr-xr-x 1 mahmoud mousatat 197121 314 Jul 16 07:21 healthcheck.sh
-rwxr-xr-x 1 mahmoud mousatat 197121 193 Jul 16 07:21 reconcile.sh
```

### File Descriptions
- **`.git/`**: Git repository for version control
- **`desired-state.txt`**: Defines the desired system configuration
- **`current-state.txt`**: Represents the actual system state
- **`reconcile.sh`**: Script that detects and corrects configuration drift
- **`healthcheck.sh`**: Script that monitors system health using MD5 checksums
- **`health.log`**: Log file containing health check results and timestamps

---

## Lab Summary

This GitOps fundamentals lab successfully demonstrated core GitOps principles through practical Linux command-line simulations:

### ✅ **Completed Tasks:**
1. **Task 1**: Git State Reconciliation - Implemented drift detection and automatic correction
2. **Task 2**: GitOps Health Monitoring - Built health checks for configuration synchronization

### 🔑 **Key Achievements:**
- **Drift Detection**: Successfully identified when current state deviated from desired state
- **Automated Reconciliation**: Automatically corrected configuration drift without manual intervention
- **Health Monitoring**: Implemented proactive monitoring using MD5 checksums for state validation
- **Audit Trail**: Created comprehensive logs of all state changes and health checks

### 🚀 **GitOps Principles Demonstrated:**
- **Declarative Configuration**: Configuration stored in Git as the single source of truth
- **Continuous Reconciliation**: Automated synchronization between desired and current state
- **Self-Healing**: Automatic correction of configuration drift
- **Observability**: Health monitoring and audit trails for system state

This lab provides a foundation for understanding how real-world GitOps tools like Argo CD and Flux operate, just at human-readable speed instead of computer speed. 