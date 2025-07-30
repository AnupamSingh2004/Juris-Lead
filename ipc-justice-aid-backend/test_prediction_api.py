#!/usr/bin/env python3
"""
Test script to verify the prediction API endpoints work correctly
"""

import requests
import json
import time

def test_prediction_endpoints():
    """Test both Flask and Django endpoints"""
    
    # Test data
    test_data = {
        "Location": "Karol Bagh",
        "Week": "2025-W29",
        "Humidity_pct": 75,
        "Rainfall_mm": 20,
        "FeverCases": 12,
        "Absenteeism_pct": 8,
        "ToiletUsage_pct": 80,
        "WaterIndex": 0.4,
        "NDVI": 0.5
    }
    
    print("🔍 Testing Prediction API Endpoints\n")
    
    # Test Flask endpoint directly
    print("1. Testing Flask endpoint directly...")
    try:
        response = requests.post(
            "http://localhost:5001/predict",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Flask endpoint working!")
            print(f"   Prediction: {result.get('prediction')}")
            print(f"   Confidence: {result.get('confidence', 0):.2%}")
        else:
            print(f"❌ Flask endpoint failed: {response.status_code}")
            print(f"   Response: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"❌ Flask endpoint error: {e}")
    
    print()
    
    # Test Django proxy endpoint (without auth)
    print("2. Testing Django proxy endpoint (no auth)...")
    try:
        response = requests.post(
            "http://localhost:8000/api/predict/",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Django proxy working!")
            print(f"   Prediction: {result.get('prediction')}")
            print(f"   Confidence: {result.get('confidence', 0):.2%}")
        else:
            print(f"❌ Django proxy failed: {response.status_code}")
            print(f"   Response: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"❌ Django proxy error: {e}")
    
    print()
    
    # Test multiple locations
    print("3. Testing multiple Delhi locations...")
    locations = ["Karol Bagh", "Connaught Place", "Dwarka", "Rohini", "Lajpat Nagar"]
    
    for location in locations:
        try:
            test_data_location = test_data.copy()
            test_data_location["Location"] = location
            
            response = requests.post(
                "http://localhost:5001/predict",
                json=test_data_location,
                headers={"Content-Type": "application/json"},
                timeout=5
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"   {location}: {result.get('prediction')} ({result.get('confidence', 0):.1%})")
            else:
                print(f"   {location}: Error {response.status_code}")
        except Exception as e:
            print(f"   {location}: Exception {e}")
    
    print()
    
    # Test health endpoint
    print("4. Testing health endpoint...")
    try:
        response = requests.get("http://localhost:5001/health", timeout=5)
        if response.status_code == 200:
            health = response.json()
            print(f"✅ Health endpoint working!")
            print(f"   Model loaded: {health.get('model_loaded')}")
            print(f"   Available locations: {health.get('available_locations')}")
        else:
            print(f"❌ Health endpoint failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Health endpoint error: {e}")

if __name__ == "__main__":
    test_prediction_endpoints()
