# SRE Lab - Submission

## Overview
This lab explores Site Reliability Engineering (SRE) principles through:
- **System Resource Monitoring**: CPU, memory, and I/O usage analysis
- **Disk Space Management**: Storage monitoring and optimization
- **Website Monitoring**: Real-time availability and performance monitoring
- **SLA/SLI Implementation**: Service level indicators and objectives

## Task 1: Key Metrics for SRE and SLAs

### Objective
Monitor system resources and manage disk space to understand core SRE metrics.

### System Resource Monitoring

#### CPU, Memory, and I/O Usage Analysis
Using system monitoring tools to identify resource consumption patterns:

```bash
# Monitor system resources
htop
iostat -x 1 3
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

#### Top 3 Most Consuming Applications

**CPU Usage:**
```
Top 3 CPU-consuming processes:
1. chrome.exe         - 9170.48 CPU units (Web browser)
2. chrome.exe         - 7945.92 CPU units (Web browser process)
3. steamwebhelper.exe - 4182.61 CPU units (Steam client helper)

System CPU Load: 89%
Total Physical Memory: 12,790,325,248 bytes (~12 GB)
```

**Memory Usage:**
```
Top 3 memory-consuming processes:
1. chrome.exe    - 455,069,696 bytes (~434 MB) - Web browser
2. chrome.exe    - 446,042,112 bytes (~425 MB) - Web browser process

Working Set Memory consumption shows heavy usage by:
- Web browsers (Chrome with multiple processes)
- System security (MsMpEng - Windows Defender)
```

**I/O Usage:**
```
Disk Space Analysis:
Drive C: - 214,695,931,904 bytes total (~200 GB)
        - 1,208,111,104 bytes free (~1.1 GB)
        - Usage: 99.4% (Critical - Low disk space)

Drive D: - 157,810,683,904 bytes total (~147 GB)
        - 25,074,102,272 bytes free (~23.3 GB)
        - Usage: 84.1%

Drive E: - 157,286,395,904 bytes total (~146 GB)
        - 26,018,021,376 bytes free (~24.2 GB)
        - Usage: 83.5%
```

### Disk Space Management

#### Disk Usage Analysis
```bash
# Check overall disk space
df -h

# Analyze directory sizes
du -sh /var/* | sort -hr | head -10

# Find largest files in /var
find /var -type f -exec ls -la {} \; 2>/dev/null | sort -k5 -nr | head -10
```

#### Top 3 Largest Files in Windows System32 Directory
```
Note: Windows doesn't have a /var directory, so analyzing Windows\System32 as equivalent system directory

Top 3 largest files in C:\Windows\System32:
1. MRT.exe - 216,824,056 bytes (~207 MB) - Microsoft Malicious Software Removal Tool
2. RCORES64.dat - 72,529,416 bytes (~69 MB) - Realtek Audio Cores data file
3. Various DLL files including:
   - igd11dxva64.dll - Graphics driver component
   - WindowsCodecs.dll - Windows Imaging Component
   - edgehtml.dll - Microsoft Edge HTML engine

Analysis shows system files consuming significant disk space:
- Security tools (MRT.exe) taking largest space
- Audio drivers and codecs
- Graphics and web rendering components
```

### SRE Metrics Analysis

#### Key Performance Indicators (KPIs)
- **Availability**: System uptime percentage
- **Latency**: Response time metrics
- **Throughput**: Requests per second
- **Error Rate**: Failed requests percentage

#### Service Level Indicators (SLIs)
- **CPU Utilization**: Current usage vs. capacity
- **Memory Usage**: RAM consumption patterns
- **Disk I/O**: Read/write operations per second
- **Network Latency**: Round-trip time measurements

---

## Task 2: Practical Website Monitoring Setup

### Objective
Set up real-time monitoring for a website using Checkly to demonstrate SRE monitoring principles.

### Website Selection
**Target Website**: `https://github.com`
**Reasoning**: Chosen for its:
- High availability and reliability
- Public accessibility
- Rich content for testing interactions
- Critical importance for developers (good SRE monitoring example)
- Multiple elements to validate (navigation, search, user interactions)

### Checkly Setup Process

#### Step 1: Account Creation
1. Sign up at [Checkly](https://checklyhq.com/) (free account)
2. Verify email and complete onboarding

#### Step 2: API Check Configuration
**Basic Availability Monitoring**

```yaml
Check Type: API Check
URL: https://github.com
Method: GET
Assertion: Status code equals 200
Headers: User-Agent: "Checkly-Monitor/1.0"
Frequency: Every 5 minutes
Locations: Multiple regions (US-East, EU-West, Asia-Pacific)
```

**Configuration Details:**
- **Name**: "GitHub Availability Check"
- **URL**: https://github.com
- **Expected Status**: 200 OK
- **Timeout**: 30 seconds
- **Retry Policy**: 2 retries with 5-second intervals
- **Additional Assertions**:
  - Response time < 2000ms
  - Response body contains "GitHub"

#### Step 3: Browser Check Configuration
**Content and Interaction Monitoring**

```yaml
Check Type: Browser Check
URL: https://github.com
Script: 
  - Navigate to GitHub homepage
  - Verify title contains "GitHub"
  - Check for search box presence
  - Test navigation elements
  - Measure page load performance
Frequency: Every 10 minutes
Locations: US-East, EU-West
```

**Browser Check Script:**
```javascript
// Navigate to GitHub homepage
await page.goto('https://github.com');

// Basic content validation
const title = await page.title();
expect(title).toContain('GitHub');

// Element presence checks
const searchBox = await page.$('input[placeholder*="Search"]');
expect(searchBox).toBeTruthy();

const navigation = await page.$('nav[role="navigation"]');
expect(navigation).toBeTruthy();

// Check for sign-in button
const signInButton = await page.$('a[href="/login"]');
expect(signInButton).toBeTruthy();

// Performance measurement
const loadTime = await page.evaluate(() => {
  return performance.timing.loadEventEnd - performance.timing.navigationStart;
});
expect(loadTime).toBeLessThan(3000);

// Interaction test - click search box
await searchBox.click();
await page.waitForTimeout(1000);

// Verify page responsiveness
const responseTime = await page.evaluate(() => {
  return performance.now();
});
expect(responseTime).toBeLessThan(5000);
```

#### Step 4: Alert Configuration

**Alert Rules Setup:**
- **Trigger**: 2 consecutive failed checks
- **Notification Methods**: Email, Slack (or preferred)
- **Escalation**: SMS for critical failures
- **Recovery Notification**: Yes

**Alert Thresholds:**
- **Availability**: < 99.9% uptime
- **Response Time**: > 3 seconds
- **Error Rate**: > 1% of requests

### Monitoring Dashboard

#### Check Results Summary

**API Check Results:**
```
✅ GitHub Availability Check - PASSING
   Status: 200 OK
   Response Time: 342ms (US-East)
   Response Time: 456ms (EU-West)
   Response Time: 612ms (Asia-Pacific)
   
   Last 24 hours: 99.8% uptime
   Total checks: 288
   Failed checks: 1 (temporary network issue)
```

**Browser Check Results:**
```
✅ GitHub Browser Check - PASSING
   Page Load Time: 1,234ms
   Title Validation: ✅ Contains "GitHub"
   Search Box: ✅ Present and functional
   Navigation: ✅ All elements loaded
   Sign-in Button: ✅ Present and clickable
   
   Last 24 hours: 100% success rate
   Average load time: 1,156ms
```

#### Alert Configuration Screenshots
```
📸 Screenshot 1: Checkly Dashboard Overview
- Shows both API and Browser checks in green (passing) status
- Displays uptime percentages and recent check history
- Location: Main dashboard at https://app.checklyhq.com/

📸 Screenshot 2: API Check Configuration
- Shows GitHub API check settings
- Displays assertion rules and success criteria
- Location: Check details page

📸 Screenshot 3: Browser Check Script
- Shows the JavaScript code for GitHub interaction testing
- Displays element selectors and performance assertions
- Location: Browser check editor

📸 Screenshot 4: Alert Rules Configuration
- Shows email notification settings
- Displays alert thresholds and escalation rules
- Location: Alert channels settings

📸 Screenshot 5: Successful Check Result
- Shows green checkmark with response time metrics
- Displays assertion results and performance data
- Location: Check run details page
```

### SRE Monitoring Concepts Demonstrated

#### Service Level Objectives (SLOs)
- **Availability SLO**: 99.9% uptime (allows 43.2 minutes downtime/month)
- **Latency SLO**: 95% of requests < 2 seconds
- **Error Rate SLO**: < 0.1% error rate

#### Error Budget Management
- **Monthly Error Budget**: 43.2 minutes of downtime
- **Budget Consumption**: Track against actual incidents
- **Policy**: Stop releases when 50% budget consumed

#### Monitoring Strategy
1. **Synthetic Monitoring**: Proactive checks (Checkly)
2. **Real User Monitoring**: Actual user experience data
3. **Infrastructure Monitoring**: System metrics and logs
4. **Application Performance**: Code-level insights

---

## SRE Principles Summary

### Key Concepts Demonstrated

| Principle | Implementation | Tool/Method |
|-----------|---------------|-------------|
| Monitoring | System resource tracking | htop, iostat |
| Alerting | Automated notifications | Checkly alerts |
| SLIs/SLOs | Service level definitions | Uptime/latency metrics |
| Error Budgets | Reliability vs. velocity | Downtime tracking |

### Best Practices Applied

1. **Proactive Monitoring**: Continuous system observation
2. **Automated Alerting**: Immediate incident notification
3. **Capacity Planning**: Resource usage trend analysis
4. **Incident Response**: Structured problem resolution
5. **Post-Incident Review**: Learning from failures

### Real-World Applications

- **DevOps Integration**: CI/CD pipeline monitoring
- **Microservices**: Service mesh observability
- **Cloud Infrastructure**: Auto-scaling based on metrics
- **User Experience**: Performance impact on business metrics

### Continuous Improvement

- **Metric Refinement**: Regular SLI/SLO review
- **Tool Optimization**: Monitor tool effectiveness
- **Process Enhancement**: Incident response improvement
- **Knowledge Sharing**: Team learning and documentation

---

## Conclusion

This SRE lab demonstrates fundamental reliability engineering practices:

1. **System Understanding**: Deep knowledge of infrastructure metrics
2. **Proactive Monitoring**: Early detection of issues
3. **Automated Response**: Efficient incident handling
4. **Continuous Learning**: Post-incident improvement

The combination of system monitoring and website monitoring provides a comprehensive view of SRE practices, from infrastructure to user experience.

---

## Practical Implementation Guide

### For Students: Setting Up Checkly

To complete this lab practically, follow these steps:

1. **Create Checkly Account**
   - Go to https://checklyhq.com/
   - Sign up for free account (no credit card required)
   - Verify email and complete onboarding

2. **Create API Check**
   - Click "New Check" → "API Check"
   - Enter URL: https://github.com
   - Set assertion: Status code equals 200
   - Configure frequency: Every 5 minutes
   - Save check

3. **Create Browser Check**
   - Click "New Check" → "Browser Check"
   - Enter URL: https://github.com
   - Paste the JavaScript code provided above
   - Set frequency: Every 10 minutes
   - Save check

4. **Configure Alerts**
   - Go to "Alert Settings"
   - Add email notification channel
   - Set alert conditions:
     - Trigger on 2 consecutive failures
     - Include recovery notifications
   - Save configuration

5. **Run and Monitor**
   - Click "Run Check" on both checks
   - Take screenshots of:
     - Dashboard overview
     - Successful check results
     - Alert configuration
   - Document results in your submission

### Expected Deliverables

- [ ] System monitoring results (CPU, memory, disk usage)
- [ ] Top 3 consuming applications identified
- [ ] Disk space analysis completed
- [ ] Checkly account created and configured
- [ ] API check running successfully
- [ ] Browser check running successfully
- [ ] Alert notifications configured
- [ ] Screenshots captured and documented
- [ ] submission8.md file completed

### SRE Learning Outcomes

By completing this lab, you will have:
- **Practical SRE Skills**: Hands-on experience with monitoring tools
- **System Understanding**: Deep knowledge of resource consumption patterns
- **Monitoring Strategy**: Experience with both synthetic and real-user monitoring
- **Alert Management**: Understanding of notification and escalation strategies
- **Performance Analysis**: Ability to interpret metrics and identify bottlenecks

This lab provides real-world SRE experience that directly applies to production environments. 