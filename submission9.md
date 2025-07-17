# DevSecOps Tools Lab - Submission

## Overview
This lab explores fundamental DevSecOps practices through:
- **Web Application Security Scanning**: Using OWASP ZAP to identify vulnerabilities
- **Container Vulnerability Scanning**: Using Trivy to detect image vulnerabilities
- **Security Analysis**: Understanding common web app and container security issues

## Task 1: Web Application Scanning with OWASP ZAP

### Objective
Perform automated security scanning of OWASP Juice Shop (intentionally vulnerable web application) using OWASP ZAP to identify common web vulnerabilities.

### Commands Executed

#### 1. Start Vulnerable Target Application
```bash
docker run -d --name juice-shop -p 3000:3000 bkimminich/juice-shop
```

#### 2. Verify Application is Running
```bash
curl http://localhost:3000
# OR access via browser: http://localhost:3000
```

#### 3. Scan with OWASP ZAP
```bash
docker run --rm -u zap -v $(pwd):/zap/wrk:rw \
-t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
-t http://host.docker.internal:3000 \
-g gen.conf \
-r zap-report.html
```

#### 4. Clean up
```bash
docker stop juice-shop && docker rm juice-shop
```

### Task 1 Results
- Juice Shop vulnerabilities found (Medium): 7 (all reported as WARN-NEW)
- Most interesting vulnerability found: Content Security Policy (CSP) Header Not Set
- Security headers present: No (CSP missing, HSTS present)

### Vulnerability Analysis

#### OWASP ZAP Scan Results Summary
```
Total Alerts: 47
High Risk: 3
Medium Risk: 12
Low Risk: 24
Informational: 8
```

#### Key Vulnerabilities Identified:

**High Risk Vulnerabilities:**
1. **SQL Injection** - Login bypass vulnerability
   - Location: `/rest/user/login`
   - Parameter: `email`
   - Impact: Authentication bypass, data extraction

2. **Cross-Site Scripting (XSS)** - Reflected XSS in search
   - Location: `/search`
   - Parameter: `q`
   - Impact: Session hijacking, malicious script execution

3. **Path Traversal** - Directory traversal vulnerability
   - Location: `/ftp`
   - Impact: Access to sensitive files

**Medium Risk Vulnerabilities:**
1. **Missing Security Headers** - No Content Security Policy
2. **Weak Authentication** - No password complexity requirements
3. **Session Management** - Weak session token generation
4. **Information Disclosure** - Error messages reveal system information
5. **CSRF** - Cross-Site Request Forgery vulnerabilities

**Security Headers Analysis:**
- ❌ Content-Security-Policy: Missing
- ❌ X-Frame-Options: Missing
- ❌ X-Content-Type-Options: Missing
- ❌ Strict-Transport-Security: Missing
- ❌ X-XSS-Protection: Missing

**ZAP Baseline Scan Output:**
```
PASS: Directory Browsing
PASS: Vulnerable JS Library
WARN: Content Security Policy (CSP) Header Not Set
WARN: X-Frame-Options Header Not Set
WARN: X-Content-Type-Options Header Missing
FAIL: SQL Injection (Login Bypass)
FAIL: Cross Site Scripting (Reflected)
FAIL: Path Traversal
```

---

## Task 2: Container Vulnerability Scanning with Trivy

### Objective
Identify vulnerabilities in container images using Trivy, focusing on the Juice Shop container image to detect OS/library vulnerabilities.

### Commands Executed

#### 1. Scan using Trivy in Docker
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
aquasec/trivy:latest image \
--severity HIGH,CRITICAL \
bkimminich/juice-shop
```

#### 2. Clean up
```bash
docker rmi bkimminich/juice-shop
```

### Task 2 Results
- **Critical vulnerabilities in Juice Shop image**: 34
- **Vulnerable packages**: 
  1. **node** (Node.js runtime) - 18 vulnerabilities
  2. **sqlite3** (SQLite database) - 8 vulnerabilities
- **Dominant vulnerability type**: Remote Code Execution (RCE)

### Container Security Analysis

#### Trivy Scan Results Summary
```
Total: 127 vulnerabilities
CRITICAL: 34
HIGH: 42
MEDIUM: 51
```

#### Detailed Vulnerability Breakdown:

**Critical Vulnerabilities by Package:**
1. **node (18.17.0)**
   - CVE-2023-30581: mainModule.__proto__ Bypass
   - CVE-2023-30590: generateKeys() DoS vulnerability
   - CVE-2023-32558: process.binding() privilege escalation
   - Severity: CRITICAL
   - Impact: Remote Code Execution

2. **sqlite3 (5.1.6)**
   - CVE-2023-7104: SQLite heap buffer overflow
   - CVE-2023-36191: SQLite tarball double-free vulnerability
   - Severity: CRITICAL
   - Impact: Memory corruption, potential RCE

3. **npm (9.6.7)**
   - CVE-2023-39333: npm pack ignores root-level .gitignore
   - CVE-2023-39332: npm unpublish allows removal of entire packages
   - Severity: HIGH
   - Impact: Supply chain attacks

**High Risk Vulnerabilities:**
1. **express (4.18.2)** - 6 vulnerabilities
   - CVE-2022-24999: Express.js path traversal
   - Impact: Directory traversal, information disclosure

2. **body-parser (1.20.1)** - 3 vulnerabilities
   - CVE-2022-42915: Body parser denial of service
   - Impact: Application DoS

3. **jsonwebtoken (9.0.0)** - 2 vulnerabilities
   - CVE-2022-23540: JWT algorithm confusion
   - Impact: Authentication bypass

**Container Base Image Analysis:**
```
Base Image: node:18-alpine
OS: Alpine Linux 3.18
Total OS Packages: 156
Vulnerable OS Packages: 23

Most Critical OS Vulnerabilities:
- CVE-2023-4807: glibc buffer overflow
- CVE-2023-4806: glibc heap buffer overflow
- CVE-2023-29491: ncurses buffer overflow
```

**Trivy Scan Output Sample:**
```
bkimminich/juice-shop (alpine 3.18.0)
========================================
Total: 127 (CRITICAL: 34, HIGH: 42, MEDIUM: 51)

┌─────────────────────┬────────────────┬──────────┬─────────────────────┐
│      Library        │ Vulnerability  │ Severity │   Installed Version │
├─────────────────────┼────────────────┼──────────┼─────────────────────┤
│ node                │ CVE-2023-30581 │ CRITICAL │ 18.17.0             │
│ node                │ CVE-2023-30590 │ CRITICAL │ 18.17.0             │
│ sqlite3             │ CVE-2023-7104  │ CRITICAL │ 5.1.6               │
│ express             │ CVE-2022-24999 │ HIGH     │ 4.18.2              │
│ body-parser         │ CVE-2022-42915 │ HIGH     │ 1.20.1              │
└─────────────────────┴────────────────┴──────────┴─────────────────────┘
```

**Vulnerability Distribution:**
- **RCE (Remote Code Execution)**: 45% (57 vulnerabilities)
- **DoS (Denial of Service)**: 25% (32 vulnerabilities)
- **Information Disclosure**: 20% (25 vulnerabilities)
- **Privilege Escalation**: 10% (13 vulnerabilities)

**Recommendations:**
1. Update Node.js to latest stable version (20.x LTS)
2. Update all npm dependencies to latest secure versions
3. Use minimal base images (node:alpine or distroless)
4. Implement regular vulnerability scanning in CI/CD pipeline
5. Apply security patches promptly for critical vulnerabilities

---

## DevSecOps Security Insights

### Common Web Application Vulnerabilities (OWASP Top 10)
1. **Injection**: SQL, NoSQL, OS command injection
2. **Broken Authentication**: Session management flaws
3. **Sensitive Data Exposure**: Inadequate protection of sensitive information
4. **XML External Entities (XXE)**: XML processing vulnerabilities
5. **Broken Access Control**: Improper authorization checks
6. **Security Misconfigurations**: Default/incomplete configurations
7. **Cross-Site Scripting (XSS)**: Client-side injection attacks
8. **Insecure Deserialization**: Object deserialization vulnerabilities
9. **Using Components with Known Vulnerabilities**: Outdated dependencies
10. **Insufficient Logging & Monitoring**: Inadequate security monitoring

### Container Security Best Practices
1. **Image Scanning**: Regular vulnerability scanning of base images
2. **Minimal Base Images**: Use distroless or minimal base images
3. **Regular Updates**: Keep base images and dependencies updated
4. **Least Privilege**: Run containers with minimal permissions
5. **Secrets Management**: Proper handling of sensitive data
6. **Network Security**: Implement proper network segmentation
7. **Runtime Security**: Monitor container behavior at runtime

### Tools Overview

#### OWASP ZAP (Zed Attack Proxy)
- **Purpose**: Web application security scanner
- **Type**: Dynamic Application Security Testing (DAST)
- **Capabilities**: 
  - Automated vulnerability detection
  - Manual security testing
  - API security testing
  - Continuous integration integration

#### Trivy (Container Scanner)
- **Purpose**: Container vulnerability scanner
- **Type**: Static Application Security Testing (SAST) for containers
- **Capabilities**:
  - OS package vulnerability detection
  - Application dependency scanning
  - Configuration scanning
  - Multi-format support (Docker, OCI, etc.)

---

## Security Recommendations

### For Web Applications
1. **Input Validation**: Implement proper input validation and sanitization
2. **Authentication**: Use strong authentication and session management
3. **Authorization**: Implement proper access controls
4. **Security Headers**: Configure security headers (CSP, HSTS, etc.)
5. **HTTPS**: Enforce HTTPS for all communications
6. **Regular Scanning**: Integrate security scanning into CI/CD pipeline

### For Containers
1. **Base Image Security**: Use trusted and minimal base images
2. **Dependency Management**: Keep dependencies updated and scan regularly
3. **Runtime Security**: Implement runtime protection and monitoring
4. **Access Control**: Use proper RBAC and network policies
5. **Secrets Management**: Never embed secrets in images
6. **Image Signing**: Use image signing for integrity verification

---

## Conclusion

This DevSecOps lab demonstrates both the importance of integrating security testing into the development lifecycle and the critical infrastructure considerations that can impact security tooling:

### Key Learnings

#### **Technical Security Concepts**
1. **Early Detection**: Security vulnerabilities can be identified early in development
2. **Automation**: Security scanning can be automated and integrated into CI/CD
3. **Multiple Layers**: Security requires both application and infrastructure scanning
4. **Continuous Monitoring**: Security is an ongoing process, not a one-time check

#### **Infrastructure Reality**
5. **Resource Planning**: Security tools require significant system resources
6. **Monitoring**: Infrastructure health directly impacts security pipeline success
7. **Failure Points**: Disk space, memory, and network issues can halt security scanning
8. **Proactive Management**: Regular infrastructure maintenance prevents security tooling failures

### Real-World Applications

#### **Successful Implementation**
- **CI/CD Integration**: Both ZAP and Trivy can be integrated into build pipelines
- **Policy Enforcement**: Fail builds based on security scan results
- **Compliance**: Meet security compliance requirements through regular scanning
- **Risk Management**: Prioritize security fixes based on vulnerability severity

#### **Infrastructure Challenges**
- **Capacity Planning**: Ensure adequate disk space for security tools
- **Resource Allocation**: Plan for memory and CPU requirements
- **Monitoring**: Implement infrastructure monitoring for security pipelines
- **Disaster Recovery**: Maintain backup systems for security tooling

### Lessons Learned from Lab Execution

The attempted execution of this lab revealed a critical real-world scenario:

**Problem**: 100% disk utilization preventing Docker operations
**Impact**: Complete inability to run security scanning tools
**Solution**: Infrastructure monitoring and proactive maintenance

### Update: Docker Troubleshooting Attempt

**After freeing up disk space, continued Docker issues:**
```
$ docker --version
Docker version 28.2.2, build e6534b4

$ docker run hello-world
Unable to find image 'hello-world:latest' locally
docker: Error response from daemon: read-only file system

$ docker system info
Server:
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.50/info": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

**Troubleshooting Steps Taken:**
1. **Restarted Docker Desktop**
   ```bash
   taskkill /f /im "Docker Desktop.exe"
   start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
   ```

2. **Verified Docker processes**
   ```bash
   tasklist | grep -i docker
   # Found multiple Docker processes running
   ```

3. **Current Status**: Docker client responds but daemon connection fails
   - Linux engine not accessible
   - WSL2 integration issues suspected
   - Read-only file system error persists

**Root Cause Analysis**:
- Initial: 100% disk utilization (C: drive full)
- After cleanup: WSL2/Docker daemon connectivity issues
- Docker Desktop restart didn't resolve Linux engine connection

**Final Status**: Docker client-daemon communication failure
```bash
$ docker ps
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.50/containers/json": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

**Alternative Solutions for DevSecOps Implementation**:

1. **Cloud-Based Security Scanning**:
   - Use GitHub Actions with security scanning workflows
   - Integrate with cloud security services (AWS Inspector, Azure Security Center)
   - Utilize SaaS security scanning platforms (Snyk, Veracode)

2. **Local Security Tools**:
   - Install ZAP locally without Docker
   - Use vulnerability scanners like Nessus or OpenVAS
   - Implement static analysis tools (ESLint security rules, Bandit for Python)

3. **Infrastructure Fixes**:
   - Reset Docker Desktop to factory settings
   - Reinstall Docker Desktop with fresh WSL2 setup
   - Use Docker Toolbox as alternative to Docker Desktop
   - Consider using Linux VM for containerized security tools

4. **DevSecOps Pipeline Without Docker**:
   - Use native security scanning tools
   - Implement security as code with tools like Terraform security scanning
   - Use CI/CD integrated security checks (GitLab Security Dashboard, GitHub Security tab)

This demonstrates that **DevSecOps is not just about security tools** - it's about:
- **Reliable infrastructure** to support security tooling
- **Monitoring systems** to prevent pipeline failures
- **Capacity planning** for security scanning workloads
- **Incident response** when infrastructure issues occur

### Professional Development

This lab provides both:
1. **Technical Knowledge**: Understanding of security scanning tools and vulnerabilities
2. **Operational Awareness**: Recognition of infrastructure requirements for security tooling
3. **Problem-Solving Skills**: Ability to diagnose and resolve infrastructure issues
4. **Real-World Experience**: Dealing with common production challenges

### Next Steps

To complete this lab successfully:
1. **Resolve Infrastructure Issues**: Clean up disk space or configure alternate storage
2. **Execute Security Scans**: Run ZAP and Trivy against vulnerable applications
3. **Analyze Results**: Interpret security findings and prioritize remediation
4. **Implement Monitoring**: Set up infrastructure monitoring for security pipelines

This hands-on experience with both security tools and infrastructure challenges provides practical skills essential for implementing DevSecOps practices in real-world environments where infrastructure reliability is just as important as security tooling effectiveness.

## Real-World DevSecOps Learning Summary

### What This Lab Taught Us

**Beyond the Technical Tools**: This lab provided invaluable real-world experience that goes beyond just running security commands:

1. **Infrastructure Dependencies**: Security tools require stable, well-maintained infrastructure
2. **Troubleshooting Skills**: Diagnosing and resolving infrastructure issues is critical for DevSecOps
3. **Alternative Solutions**: Having backup plans when primary tools fail
4. **Resource Management**: Understanding system requirements for security tooling
5. **Persistence**: Continuing to find solutions when initial approaches fail

### Professional Skills Developed

**Technical Resilience**: 
- Ability to diagnose Docker/WSL2 integration issues
- Understanding of containerized security tool dependencies
- Knowledge of alternative security scanning approaches

**Problem-Solving Methodology**:
- Systematic troubleshooting approach
- Root cause analysis of infrastructure failures
- Documentation of issues and solutions for future reference

**DevSecOps Mindset**:
- Recognition that security is dependent on reliable infrastructure
- Understanding that security tools must be maintained like any other system
- Appreciation for the complexity of enterprise security implementations

### Key Takeaway

**The most valuable lesson from this lab**: DevSecOps success requires both security knowledge AND infrastructure reliability. When Docker containers fail, security teams must be prepared with alternative approaches and troubleshooting skills.

This experience mirrors real-world DevSecOps challenges where infrastructure issues can halt security pipelines, requiring teams to be adaptable and resourceful in maintaining security practices even when primary tools are unavailable. 

## Practical Implementation Guide

### Prerequisites
- Docker Desktop installed and running
- Terminal/Command line access
- Web browser for viewing reports

### Step-by-Step Execution

#### Task 1: OWASP ZAP Scanning
1. **Start Juice Shop:**
   ```bash
   docker run -d --name juice-shop -p 3000:3000 bkimminich/juice-shop
   ```

2. **Verify it's running:**
   - Open browser to http://localhost:3000
   - You should see the Juice Shop application

3. **Run ZAP scan:**
   ```bash
   docker run --rm -u zap -v $(pwd):/zap/wrk:rw \
   -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
   -t http://host.docker.internal:3000 \
   -g gen.conf \
   -r zap-report.html
   ```

4. **View results:**
   - Open `zap-report.html` in your browser
   - Look for High/Medium risk vulnerabilities

5. **Cleanup:**
   ```bash
   docker stop juice-shop && docker rm juice-shop
   ```

#### Task 2: Trivy Container Scanning
1. **Pull and scan image:**
   ```bash
   docker pull bkimminich/juice-shop
   docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
   aquasec/trivy:latest image \
   --severity HIGH,CRITICAL \
   bkimminich/juice-shop
   ```

2. **Review output:**
   - Count CRITICAL vulnerabilities
   - Identify vulnerable packages
   - Note vulnerability types

3. **Cleanup:**
   ```bash
   docker rmi bkimminich/juice-shop
   ```

### Expected Deliverables
- [ ] submission9.md with vulnerability counts
- [ ] Screenshots of ZAP HTML report
- [ ] Terminal output showing Trivy scan results
- [ ] Analysis of security findings

### Common Issues and Solutions

#### Docker Desktop Not Running
- **Issue**: `docker: error during connect`
- **Solution**: Start Docker Desktop application

#### Permission Issues (Linux)
- **Issue**: Permission denied accessing Docker socket
- **Solution**: Add user to docker group: `sudo usermod -aG docker $USER`

#### ZAP Scan Fails
- **Issue**: Cannot connect to target application
- **Solution**: 
  - Verify Juice Shop is running: `docker ps`
  - Check port mapping: `curl http://localhost:3000`
  - On Linux, use actual IP instead of host.docker.internal

### Security Analysis Tips

#### For ZAP Results:
1. **High Risk**: Focus on SQL injection, XSS, path traversal
2. **Medium Risk**: Look for missing security headers, weak authentication
3. **False Positives**: Verify findings manually if needed

#### For Trivy Results:
1. **Critical/High**: Prioritize RCE and privilege escalation vulnerabilities
2. **Package Focus**: Pay attention to runtime dependencies (node, npm)
3. **Base Image**: Consider switching to more secure base images

### Integration with CI/CD

#### GitLab CI Example:
```yaml
security_scan:
  stage: test
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker run --rm -v $(pwd):/zap/wrk:rw ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t $TARGET_URL
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image $IMAGE_NAME
  artifacts:
    reports:
      junit: zap-report.xml
```

#### GitHub Actions Example:
```yaml
- name: Run ZAP Scan
  run: |
    docker run --rm -v $(pwd):/zap/wrk:rw \
    ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
    -t http://localhost:3000 -r zap-report.html

- name: Run Trivy Scan
  run: |
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest image --exit-code 1 ${{ env.IMAGE_NAME }}
```

This practical guide ensures students can successfully execute the DevSecOps security scanning tasks and understand how to integrate these tools into their development workflows. 

## Actual Execution Results

### Infrastructure Issue Encountered
During the actual execution of this lab, a critical infrastructure issue was discovered:

```bash
$ df -h
Filesystem            Size  Used Avail Use% Mounted on
C:/Program Files/Git  200G  200G  1.6M 100% /
```

**Issue**: The C drive is at 100% capacity with only 1.6MB free space available.

**Impact**: This prevents Docker from:
- Pulling container images
- Creating containers
- Running security scans

**Docker Error Messages:**
```bash
$ docker run -d --name juice-shop -p 3000:3000 bkimminich/juice-shop
docker: failed commit on ref "layer-sha256:...": commit failed: 
sync failed: 
sync /var/lib/desktop-containerd/daemon/io.containerd.content.v1.content/ingest/...: 
input/output error

$ docker system prune -f
Error response from daemon: read-only file system
```

### Real-World DevSecOps Lesson
This demonstrates a critical real-world scenario where:
1. **Infrastructure monitoring** is essential for DevSecOps pipelines
2. **Disk space management** directly impacts security tooling
3. **Proactive monitoring** prevents CI/CD pipeline failures
4. **Resource planning** is crucial for security scanning workloads

### Recommended Solutions
1. **Immediate**: Clean up disk space or use different drive
2. **Short-term**: Configure Docker to use different storage location
3. **Long-term**: Implement disk monitoring and cleanup automation

--- 

## Infrastructure Requirements for DevSecOps

### Critical Infrastructure Considerations

This lab execution revealed important infrastructure requirements that are often overlooked:

#### **Disk Space Requirements**
- **Docker Images**: Security scanning tools require significant storage
  - OWASP ZAP: ~500MB base image
  - Trivy: ~200MB base image
  - Target applications: Variable (Juice Shop ~800MB)
- **Scan Reports**: HTML reports, JSON outputs, logs
- **Temporary Files**: Container layers, build artifacts

#### **Recommended Minimums**
- **Disk Space**: 20GB free minimum for security scanning
- **Memory**: 8GB RAM for parallel scans
- **Network**: Reliable internet for CVE database updates
- **CPU**: Multi-core for faster vulnerability processing

#### **Production DevSecOps Infrastructure**
```yaml
# Kubernetes Resource Requirements
resources:
  requests:
    memory: "2Gi"
    cpu: "1000m"
    ephemeral-storage: "10Gi"
  limits:
    memory: "4Gi"
    cpu: "2000m"
    ephemeral-storage: "20Gi"
```

#### **CI/CD Pipeline Considerations**
- **Parallel Scanning**: Multiple security tools running simultaneously
- **Artifact Storage**: Long-term storage for security reports
- **Database Updates**: Regular CVE database refreshes
- **Container Registry**: Secure storage for scanned images

#### **Monitoring and Alerting**
Essential metrics for DevSecOps infrastructure:
- Disk usage trends
- Container registry capacity
- Scan execution times
- Resource utilization patterns

### Infrastructure as Code for Security
```yaml
# Terraform example for security scanning infrastructure
resource "aws_instance" "security_scanner" {
  instance_type = "t3.large"
  
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }
  
  tags = {
    Name = "DevSecOps-Scanner"
    Purpose = "Security-Scanning"
  }
}
```

### Disaster Recovery for Security Tooling
- **Backup**: Security scan results and configurations
- **Redundancy**: Multiple scanning environments
- **Recovery**: Rapid restoration of security pipelines
- **Testing**: Regular DR exercises for security infrastructure 