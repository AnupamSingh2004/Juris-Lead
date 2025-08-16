"""
Test script to verify the adaptive analysis service works correctly
Run this with: python manage.py shell < test_analysis_service.py
"""

from ipc_analysis.adaptive_service import adaptive_analysis_service

# Test case description
test_case = """
A man named Raj was driving his car recklessly on a busy road. Due to his negligent driving, 
he hit a pedestrian who later died in the hospital. The investigation revealed that Raj was 
not under the influence of alcohol but was driving at excessive speed and using his mobile phone.
"""

print("=== Testing Adaptive Analysis Service ===")

# Get service info
service_info = adaptive_analysis_service.get_service_info()
print(f"\nService Info:")
print(f"- Using Hugging Face: {service_info['using_huggingface']}")
print(f"- Environment: {service_info['environment']}")
print(f"- Primary Service: {service_info['primary_service']}")
print(f"- Debug Mode: {service_info['debug_mode']}")

# Health check
print(f"\n=== Health Check ===")
health = adaptive_analysis_service.health_check()
print(f"Health Status: {health}")

# Test analysis
print(f"\n=== Testing Analysis ===")
print(f"Test Case: {test_case[:100]}...")

result = adaptive_analysis_service.analyze_case(test_case)

print(f"\nResult:")
print(f"- Success: {result.get('success')}")
print(f"- Service Used: {result.get('service_used')}")
print(f"- Response Time: {result.get('response_time_ms')}ms")

if result.get('success'):
    analysis = result.get('analysis')
    if analysis:
        print(f"\nAnalysis:")
        print(f"- Sections Applied: {len(analysis.get('sections_applied', []))}")
        for section in analysis.get('sections_applied', []):
            print(f"  * Section {section.get('section_number')}: {section.get('description')}")
        print(f"- Explanation: {analysis.get('explanation', 'N/A')[:200]}...")
else:
    print(f"- Error: {result.get('error')}")

print(f"\n=== Test Complete ===")
