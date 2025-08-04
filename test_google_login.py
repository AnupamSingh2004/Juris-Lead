import requests
import json

# Test Google login for both client and lawyer
def test_google_login():
    url = "http://localhost:8001/api/v1/auth/google/login/"
    
    # Mock Google token for testing (you would use real token in actual test)
    test_data_client = {
        "access_token": "mock_token_for_testing",
        "user_role": "client",
        "email": "testclient@example.com",
        "first_name": "Test",
        "last_name": "Client",
        "google_id": "12345"
    }
    
    test_data_lawyer = {
        "access_token": "mock_token_for_testing", 
        "user_role": "lawyer",
        "email": "testlawyer@example.com",
        "first_name": "Test",
        "last_name": "Lawyer",
        "google_id": "67890"
    }
    
    print("Testing Client Login:")
    try:
        response = requests.post(url, json=test_data_client, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\nTesting Lawyer Login:")
    try:
        response = requests.post(url, json=test_data_lawyer, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_google_login()
