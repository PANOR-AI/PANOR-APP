#!/usr/bin/env python3
"""
PANOR Authentication System - Integration Test Suite

Tests all auth endpoints end-to-end:
1. Registration with multiple roles
2. Login and token generation
3. OTP flow
4. PIN setup and verification
5. Password reset flow
6. Refresh token rotation
7. Logout invalidation
"""

import requests
import json
import time
from datetime import datetime

BASE_URL = "http://localhost:8000/api"
HEADERS = {"Content-Type": "application/json"}

# Color codes for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_test(title, status, details=""):
    emoji = "✓" if status else "✗"
    color = GREEN if status else RED
    print(f"{color}[{emoji}] {title}{RESET}")
    if details:
        print(f"    {details}")

def print_section(title):
    print(f"\n{BLUE}{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}{RESET}\n")

def test_registration():
    """Test user registration with different roles"""
    print_section("1. REGISTRATION TESTS")
    
    test_users = [
        {
            "email": f"patient_{int(time.time())}@panor.test",
            "full_name": "John Patient",
            "role": "Patient",
            "phone": "9876543210",
            "password": "Test@1234"
        },
        {
            "email": f"doctor_{int(time.time())}@panor.test",
            "full_name": "Dr. Sarah Doctor",
            "role": "Doctor",
            "phone": "9876543211",
            "password": "Test@1234"
        }
    ]
    
    registered_users = []
    
    for user in test_users:
        try:
            response = requests.post(
                f"{BASE_URL}/auth/register",
                headers=HEADERS,
                json=user
            )
            status = response.status_code == 200
            if status:
                data = response.json()
                registered_users.append({**user, "id": data['data']['id']})
                print_test(f"Register {user['role']}", status, 
                          f"Email: {user['email']}, ID: {data['data']['id']}")
            else:
                print_test(f"Register {user['role']}", False, 
                          f"Status: {response.status_code}, Response: {response.text[:100]}")
        except Exception as e:
            print_test(f"Register {user['role']}", False, str(e))
    
    return registered_users

def test_login(users):
    """Test login and JWT generation"""
    print_section("2. LOGIN & JWT TESTS")
    
    tokens = []
    
    for user in users:
        try:
            data = {
                'username': user['email'],
                'password': user['password']
            }
            response = requests.post(
                f"{BASE_URL}/auth/login",
                data=data
            )
            status = response.status_code == 200
            if status:
                token_data = response.json()
                tokens.append({
                    "email": user['email'],
                    "role": user['role'],
                    "access_token": token_data['access_token'],
                    "refresh_token": token_data.get('refresh_token')
                })
                print_test(f"Login {user['role']}", status,
                          f"Access token: {token_data['access_token'][:30]}...")
            else:
                print_test(f"Login {user['role']}", False,
                          f"Status: {response.status_code}")
        except Exception as e:
            print_test(f"Login {user['role']}", False, str(e))
    
    return tokens

def test_get_current_user(tokens):
    """Test /auth/me endpoint"""
    print_section("3. CURRENT USER ENDPOINT TESTS")
    
    for token in tokens:
        try:
            headers = {**HEADERS, "Authorization": f"Bearer {token['access_token']}"}
            response = requests.get(
                f"{BASE_URL}/auth/me",
                headers=headers
            )
            status = response.status_code == 200
            if status:
                data = response.json()
                print_test(f"Get current user ({token['role']})", status,
                          f"Email: {data['data']['email']}, Role: {data['data']['role']}")
            else:
                print_test(f"Get current user ({token['role']})", False,
                          f"Status: {response.status_code}")
        except Exception as e:
            print_test(f"Get current user ({token['role']})", False, str(e))

def test_otp_flow(users):
    """Test OTP request and verification"""
    print_section("4. OTP VERIFICATION FLOW")
    
    # Request OTP
    user = users[0]  # Use first patient
    try:
        response = requests.post(
            f"{BASE_URL}/auth/request-otp?phone={user['phone']}",
            headers=HEADERS
        )
        status = response.status_code == 200
        if status:
            data = response.json()
            otp = data['data'].get('otp_for_testing')
            print_test(f"Request OTP for {user['phone']}", status,
                      f"OTP: {otp}")
            
            # Verify OTP
            if otp:
                verify_response = requests.post(
                    f"{BASE_URL}/auth/verify-otp?phone={user['phone']}&otp={otp}",
                    headers=HEADERS
                )
                verify_status = verify_response.status_code == 200
                if verify_status:
                    verify_data = verify_response.json()
                    print_test("Verify OTP", verify_status,
                              f"Access token: {verify_data['data']['access_token'][:30]}...")
                else:
                    print_test("Verify OTP", False,
                              f"Status: {verify_response.status_code}")
        else:
            print_test("Request OTP", False,
                      f"Status: {response.status_code}")
    except Exception as e:
        print_test("OTP Flow", False, str(e))

def test_pin_flow(tokens):
    """Test PIN setup and verification"""
    print_section("5. PIN SETUP & VERIFICATION FLOW")
    
    token = tokens[0]  # Use first user
    pin = "1234"
    
    try:
        # Set PIN
        headers = {**HEADERS, "Authorization": f"Bearer {token['access_token']}"}
        response = requests.post(
            f"{BASE_URL}/auth/set-pin",
            headers=headers,
            json={"pin": pin}
        )
        set_status = response.status_code == 200
        print_test(f"Set PIN {pin}", set_status)
        
        if set_status:
            # Verify PIN
            verify_response = requests.post(
                f"{BASE_URL}/auth/verify-pin?email={token['email']}&pin={pin}",
                headers=HEADERS
            )
            verify_status = verify_response.status_code == 200
            if verify_status:
                verify_data = verify_response.json()
                print_test("Verify PIN", verify_status,
                          f"Access token: {verify_data['data']['access_token'][:30]}...")
            else:
                print_test("Verify PIN", False,
                          f"Status: {verify_response.status_code}")
    except Exception as e:
        print_test("PIN Flow", False, str(e))

def test_password_reset(users):
    """Test forgot password and reset password flow"""
    print_section("6. PASSWORD RESET FLOW")
    
    user = users[0]
    new_password = "NewTest@5678"
    
    try:
        # Request password reset
        response = requests.post(
            f"{BASE_URL}/auth/forgot-password?email={user['email']}",
            headers=HEADERS
        )
        status = response.status_code == 200
        if status:
            data = response.json()
            reset_token = data['data'].get('reset_token_for_testing')
            print_test(f"Request password reset for {user['email']}", status,
                      f"Reset token: {reset_token[:20]}..." if reset_token else "")
            
            # Reset password
            if reset_token:
                reset_response = requests.post(
                    f"{BASE_URL}/auth/reset-password",
                    headers=HEADERS,
                    json={
                        "email": user['email'],
                        "reset_token": reset_token,
                        "new_password": new_password
                    }
                )
                reset_status = reset_response.status_code == 200
                print_test("Reset password", reset_status)
                
                if reset_status:
                    # Try login with new password
                    login_response = requests.post(
                        f"{BASE_URL}/auth/login",
                        data={
                            "username": user['email'],
                            "password": new_password
                        }
                    )
                    login_status = login_response.status_code == 200
                    print_test("Login with new password", login_status)
        else:
            print_test("Request password reset", False,
                      f"Status: {response.status_code}")
    except Exception as e:
        print_test("Password reset flow", False, str(e))

def test_refresh_token(tokens):
    """Test refresh token rotation"""
    print_section("7. REFRESH TOKEN ROTATION")
    
    token = tokens[0]
    if not token.get('refresh_token'):
        print(f"{YELLOW}[!] No refresh token available{RESET}")
        return
    
    try:
        response = requests.post(
            f"{BASE_URL}/auth/refresh",
            headers=HEADERS,
            json={"token": token['refresh_token']}
        )
        status = response.status_code == 200
        if status:
            data = response.json()
            new_token = data['access_token']
            print_test("Refresh access token", status,
                      f"New token: {new_token[:30]}...")
        else:
            print_test("Refresh access token", False,
                      f"Status: {response.status_code}")
    except Exception as e:
        print_test("Refresh token", False, str(e))

def test_logout(tokens):
    """Test logout invalidation"""
    print_section("8. LOGOUT TESTS")
    
    token = tokens[0]
    
    try:
        headers = {**HEADERS, "Authorization": f"Bearer {token['access_token']}"}
        response = requests.post(
            f"{BASE_URL}/auth/logout",
            headers=headers
        )
        status = response.status_code == 200
        print_test(f"Logout", status)
    except Exception as e:
        print_test("Logout", False, str(e))

def main():
    """Run all tests"""
    print(f"\n{BLUE}{'='*60}")
    print(f"  PANOR AUTHENTICATION SYSTEM - Integration Tests")
    print(f"  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}{RESET}\n")
    
    try:
        # Test registration
        users = test_registration()
        if not users:
            print(f"{RED}[!] Registration failed, cannot continue tests{RESET}")
            return
        
        # Test login
        tokens = test_login(users)
        if not tokens:
            print(f"{RED}[!] Login failed, cannot continue tests{RESET}")
            return
        
        # Test current user endpoint
        test_get_current_user(tokens)
        
        # Test OTP flow
        test_otp_flow(users)
        
        # Test PIN flow
        test_pin_flow(tokens)
        
        # Test password reset
        test_password_reset(users)
        
        # Test refresh token
        test_refresh_token(tokens)
        
        # Test logout
        test_logout(tokens)
        
        print(f"\n{GREEN}[✓] All tests completed!{RESET}\n")
        
    except requests.exceptions.ConnectionError:
        print(f"{RED}[✗] ERROR: Cannot connect to API at {BASE_URL}{RESET}")
        print(f"    Make sure the backend is running on http://localhost:8000")

if __name__ == "__main__":
    main()
