#!/bin/bash

# Network Troubleshooting Script for Flutter-Django Connection

echo "🔍 Network Troubleshooting for AarogyaRekha Flutter-Django Connection"
echo "=================================================================="

# Check if backend is running
echo "1. Checking if backend is running on localhost:8000..."
if curl -s http://localhost:8000/api/health/ > /dev/null; then
    echo "✅ Backend is running on localhost:8000"
    echo "   Response: $(curl -s http://localhost:8000/api/health/)"
else
    echo "❌ Backend is NOT running on localhost:8000"
    echo "   Make sure to run: cd aarogyarekha-backend && docker-compose up"
fi

echo ""

# Get host IP addresses
echo "2. Getting host IP addresses..."
echo "   Primary IP: $(hostname -I | awk '{print $1}')"
echo "   All IPs:"
ip addr show | grep -E 'inet.*192\.168|inet.*10\.' | while read line; do
    echo "   - $line"
done

echo ""

# Check Docker containers
echo "3. Checking Docker containers..."
if command -v docker &> /dev/null; then
    echo "   Docker containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAME|aarogyarekha)"
else
    echo "   Docker not found or not running"
fi

echo ""

# Test network connectivity from different addresses
echo "4. Testing network connectivity..."
HOST_IP=$(hostname -I | awk '{print $1}')

echo "   Testing localhost:8000..."
if curl -s --connect-timeout 5 http://localhost:8000/api/health/ > /dev/null; then
    echo "   ✅ localhost:8000 - OK"
else
    echo "   ❌ localhost:8000 - FAILED"
fi

echo "   Testing 127.0.0.1:8000..."
if curl -s --connect-timeout 5 http://127.0.0.1:8000/api/health/ > /dev/null; then
    echo "   ✅ 127.0.0.1:8000 - OK"
else
    echo "   ❌ 127.0.0.1:8000 - FAILED"
fi

echo "   Testing $HOST_IP:8000..."
if curl -s --connect-timeout 5 http://$HOST_IP:8000/api/health/ > /dev/null; then
    echo "   ✅ $HOST_IP:8000 - OK"
else
    echo "   ❌ $HOST_IP:8000 - FAILED"
fi

echo ""

# Recommendations
echo "5. Recommendations for Flutter app:"
echo "   📱 For Android Emulator:"
echo "      Set API_BASE_URL=http://10.0.2.2:8000/api"
echo ""
echo "   📱 For Physical Android Device:"
echo "      Set API_BASE_URL=http://$HOST_IP:8000/api"
echo ""
echo "   💻 For Desktop/Web:"
echo "      Set API_BASE_URL=http://localhost:8000/api"
echo ""

# Check current Flutter config
echo "6. Current Flutter configuration:"
if [ -f "../frontend/.env" ]; then
    echo "   Current .env file:"
    cat ../frontend/.env | grep API_BASE_URL
else
    echo "   .env file not found"
fi

echo ""
echo "✅ Troubleshooting complete!"
echo "💡 If you're still having issues, make sure:"
echo "   - Docker backend is running: docker-compose up"
echo "   - Firewall allows port 8000"
echo "   - Android emulator can reach host network"
