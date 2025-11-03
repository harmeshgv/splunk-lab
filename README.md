# Splunk Logging Setup Guide

## Overview
This guide helps you set up Splunk for centralized logging of any application. Splunk provides a powerful platform for collecting, analyzing, and visualizing log data.

---

## 🚀 Quick Setup (Automated)

### For Easy Splunk Setup:
```bash
# Run the automated setup script
./splunk-setup.sh
```

**The script will:**
- Remove any existing Splunk containers
- Start a fresh Splunk instance
- Configure proper license acceptance
- Map all necessary ports
- Wait for Splunk to initialize
- Display access information

---

##  Manual Step-by-Step Setup

### Step 1: Remove Existing Containers
```bash
# Remove any existing Splunk container
docker rm -f splunk
```

### Step 2: Run Splunk Container
```bash
docker run -d \
  --name splunk \
  -p 8000:8000 \
  -p 8088:8088 \
  -p 8089:8089 \
  -e SPLUNK_START_ARGS="--accept-license" \
  -e SPLUNK_GENERAL_TERMS="--accept-sgt-current-at-splunk-com" \
  -e SPLUNK_PASSWORD="admin12345" \
  splunk/splunk:latest
```

### Step 3: Verify Installation
```bash
# Check container status
docker ps

# Check logs (wait 30 seconds after container starts)
docker logs splunk

# Check all containers
docker ps -a
```

### Step 4: Access Splunk Web UI
- **URL**: http://localhost:8000
- **Username**: `admin`
- **Password**: `admin12345`

---

## Configure HTTP Event Collector (HEC)

### In Splunk Web UI:

1. **Navigate to Settings**:
   - Go to **Settings** → **Data Inputs**

2. **Create HTTP Event Collector**:
   - Click **HTTP Event Collector**
   - Click **New Token**
   - Set Name: `my-app-logs` (use descriptive name for your application)
   - Select index (create new or use `main`)
   - Complete setup
   - **Copy the generated token** (you'll need this for your application)

3. **Token Value Example**:
   ```
   eb6ba566-abfb-4640-bbe6-8d8c183e5132
   ```

---

## Configure Your Application

### For any programming language, configure:

#### Environment Variables:
```bash
export SPLUNK_HEC_TOKEN="your-token-here"
export SPLUNK_HEC_URL="http://localhost:8088"
export SPLUNK_INDEX="main"
export SPLUNK_SOURCE="your-app-name"
```

#### Python Example:
```python
import requests
import json
import logging

class SplunkHandler:
    def __init__(self, token, url, index="main", source="python-app"):
        self.token = token
        self.url = f"{url}/services/collector/event"
        self.index = index
        self.source = source

    def send_log(self, message, level="info", metadata=None):
        payload = {
            "event": {
                "message": message,
                "level": level,
                "metadata": metadata or {}
            },
            "index": self.index,
            "source": self.source
        }

        headers = {
            "Authorization": f"Splunk {self.token}",
            "Content-Type": "application/json"
        }

        response = requests.post(self.url, json=payload, headers=headers)
        return response.status_code
```

#### Node.js Example:
```javascript
const axios = require('axios');

class SplunkLogger {
    constructor(token, url, index = 'main', source = 'nodejs-app') {
        this.token = token;
        this.url = `${url}/services/collector/event`;
        this.index = index;
        this.source = source;
    }

    async sendLog(message, level = 'info', metadata = {}) {
        const payload = {
            event: {
                message,
                level,
                metadata
            },
            index: this.index,
            source: this.source
        };

        const headers = {
            Authorization: `Splunk ${this.token}`,
            'Content-Type': 'application/json'
        };

        try {
            const response = await axios.post(this.url, payload, { headers });
            return response.status;
        } catch (error) {
            console.error('Splunk log error:', error);
        }
    }
}
```

#### Java Example:
```java
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class SplunkLogger {
    private final String token;
    private final String url;
    private final String index;
    private final String source;

    public SplunkLogger(String token, String url, String index, String source) {
        this.token = token;
        this.url = url + "/services/collector/event";
        this.index = index;
        this.source = source;
    }

    public int sendLog(String message, String level, String metadata) {
        // Implementation for Java HTTP client
    }
}
```

---

##  View Your Application Logs in Splunk

### After your application is running with Splunk logging:

1. **Open Splunk Web UI**: http://localhost:8000

2. **Search your logs**:
   - In the search bar, enter:
     ```
     index="your-index-name" "your-app-name"
     ```
   - Replace placeholders with your actual values

3. **Common search queries**:
   ```spl
   # Search for errors
   index="main" level="error"

   # Search by application name
   index="main" source="your-app-name"

   # Search within time range
   index="main" earliest=-1h

   # Search specific messages
   index="main" "specific error message"
   ```

4. **Create dashboards** (optional):
   - Go to **Dashboards** → **Create New Dashboard**
   - Add panels to visualize your log data
   - Create alerts for specific error patterns
   - Monitor application performance metrics

---

##  Maintenance Commands

### Check Splunk Status:
```bash
docker ps | grep splunk
docker logs splunk
```

### Stop Splunk:
```bash
docker stop splunk
```

### Start Splunk:
```bash
docker start splunk
```

### Restart Splunk:
```bash
docker restart splunk
```

### Remove Splunk Completely:
```bash
./docker-cleanup.sh
```

### Backup Splunk Data:
```bash
docker exec splunk tar czf /tmp/splunk-backup.tar.gz /opt/splunk/var
docker cp splunk:/tmp/splunk-backup.tar.gz ./
```

---

##  Troubleshooting

### Common Issues:

1. **Container not starting**:
   ```bash
   docker logs splunk
   docker inspect splunk
   ```

2. **Port conflicts**:
   ```bash
   # Check what's using the ports
   sudo lsof -i :8000
   sudo lsof -i :8088
   sudo lsof -i :8089
   ```

3. **Can't access Web UI**:
   - Wait 30-60 seconds for Splunk to initialize completely
   - Check container health: `docker ps`
   - Verify ports are mapped correctly: `docker port splunk`

4. **Logs not appearing in Splunk**:
   - Verify HEC token is correct in your application
   - Check if HEC is enabled in Splunk Settings
   - Test connectivity: `curl -k https://localhost:8088`
   - Check Splunk internal logs: `docker exec splunk tail -f /opt/splunk/var/log/splunk/splunkd.log`

5. **Authentication issues**:
   - Default credentials: admin / admin12345
   - Reset password: `docker exec -it splunk /opt/splunk/bin/splunk edit user admin -password newpassword -auth admin:admin12345`

---

##  Best Practices

### Logging Guidelines:
- **Structured Logging**: Use JSON format for logs
- **Consistent Levels**: Use standard levels (debug, info, warn, error)
- **Context Information**: Include timestamps, user IDs, request IDs
- **Sensitive Data**: Never log passwords, tokens, or personal information

### Splunk Configuration:
- **Index Management**: Create separate indexes for different applications
- **Retention Policies**: Set appropriate data retention periods
- **User Management**: Create separate users for different teams
- **Monitoring**: Set up alerts for critical errors

---

##  Summary

### Quick Start:
1. Run `./splunk-setup.sh`
2. Access http://localhost:8000 (admin/admin12345)
3. Create HEC token in Settings → Data Inputs
4. Configure your application with the token
5. Search logs in Splunk using your application name

### Typical Workflow:
```bash
# 1. Setup
./splunk-setup.sh

# 2. Get HEC token from Splunk UI

# 3. Configure app with token

# 4. View logs in Splunk UI
# Search: index="main" source="your-app-name"

# 5. Cleanup when done
./docker-cleanup.sh
```

This setup provides a complete centralized logging solution that works with any application regardless of programming language or framework.