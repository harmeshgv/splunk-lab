#!/bin/bash

echo "🧹 Starting Splunk Docker Cleanup..."

echo "1. Stopping Splunk container..."
docker stop splunk 2>/dev/null

echo "2. Removing Splunk container..."
docker rm -f splunk 2>/dev/null

echo "3. Removing Splunk image..."
docker rmi -f splunk/splunk:latest 2>/dev/null

echo "4. Cleaning up unused Docker data..."
docker system prune -f

echo "5. Checking cleanup results..."
echo "   Containers running: $(docker ps --filter "name=splunk" --format "{{.Names}}" | wc -l)"
echo "   Splunk images: $(docker images "splunk/splunk" -q | wc -l)"

echo "✅ Splunk cleanup completed!"
echo "   Ports 8000, 8088, 8089 are now free"