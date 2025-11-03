#!/bin/bash

echo "Starting Splunk Setup..."

echo "Remove existing container if it exists"
docker rm -f splunk

echo "Run Splunk with proper license acceptance"
docker run -d \
  --name splunk \
  -p 8000:8000 \
  -p 8088:8088 \
  -p 8089:8089 \
  -e SPLUNK_START_ARGS="--accept-license" \
  -e SPLUNK_GENERAL_TERMS="--accept-sgt-current-at-splunk-com" \
  -e SPLUNK_PASSWORD="admin12345" \
  splunk/splunk:latest

echo "Waiting for Splunk to start up completely..."
sleep 30

echo "Check if container is running"
docker ps

echo "Check container logs"
docker logs splunk

echo ""
echo "================================================"
echo "🎉 Splunk Setup Complete!"
echo "================================================"
echo "Access Splunk Web UI at: http://localhost:8000"
echo "Username: admin"
echo "Password: admin12345"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:8000 in your browser"
echo "2. Login with admin/admin12345"
echo "3. Go to Settings → Data Inputs → HTTP Event Collector"
echo "4. Create new token for your application logs"
echo "================================================"