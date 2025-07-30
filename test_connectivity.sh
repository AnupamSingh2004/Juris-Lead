#!/bin/bash

# Test connectivity to backend from different IPs
echo "Testing backend connectivity..."
echo "=============================="

# Test localhost
echo "Testing localhost:8000..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8000/api/health/ || echo "Failed to connect to localhost:8000"

# Test host IP
echo "Testing 192.168.165.1:8000..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://192.168.165.1:8000/api/health/ || echo "Failed to connect to 192.168.165.1:8000"

# Test emulator IP (this will likely fail from host but shows the expected behavior)
echo "Testing 10.0.2.2:8000 (emulator perspective)..."
curl -s -o /dev/null -w "Status: %{http_code}\n" --connect-timeout 5 http://10.0.2.2:8000/api/health/ || echo "Failed to connect to 10.0.2.2:8000 (expected from host)"

echo "=============================="
echo "Backend should be accessible from:"
echo "- Host machine: http://localhost:8000 or http://192.168.165.1:8000"
echo "- Android emulator: http://10.0.2.2:8000"
echo "- Physical device: http://192.168.165.1:8000"
