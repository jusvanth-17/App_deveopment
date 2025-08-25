import os
import json
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Test the local function
def test_local_function():
    print("Testing local function...")
    
    # Test root endpoint
    try:
        response = requests.get("http://localhost:8080/")
        print(f"Root endpoint response: {response.status_code}")
        print(json.dumps(response.json(), indent=2))
        print("Root endpoint test successful!")
    except Exception as e:
        print(f"Root endpoint test failed: {str(e)}")
    
    # Test syllabus endpoint
    try:
        response = requests.post(
            "http://localhost:8080/api/syllabus",
            json={"language": "Spanish"}
        )
        print(f"Syllabus endpoint response: {response.status_code}")
        result = response.json()
        print(f"Language: {result['language']}")
        print(f"Status: {result['status']}")
        print("Syllabus sample (first 100 chars):")
        print(result['syllabus_markdown'][:100] + "...")
        print("Syllabus endpoint test successful!")
    except Exception as e:
        print(f"Syllabus endpoint test failed: {str(e)}")

if __name__ == "__main__":
    print("Make sure your function is running locally first with:")
    print("python main.py")
    input("Press Enter to continue with the test...")
    test_local_function()
