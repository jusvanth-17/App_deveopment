import os
import json
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def generate_syllabus_example():
    """Generate an example syllabus for Spanish to demonstrate normal and elaborated formats"""
    
    url = "http://127.0.0.1:8080/api/syllabus"
    headers = {"Content-Type": "application/json"}
    data = {"language": "Spanish"}
    
    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()  # Raise exception for 4XX/5XX responses
        
        result = response.json()
        
        print("\n\n=========== NORMAL SYLLABUS ===========\n")
        print(result.get("syllabus_markdown", "No syllabus found"))
        
        print("\n\n=========== ELABORATED SYLLABUS ===========\n")
        print(result.get("elaborated_syllabus_markdown", "No elaborated syllabus found"))
        
        # Save to files for easier viewing
        with open("normal_syllabus_example.md", "w") as f:
            f.write(result.get("syllabus_markdown", ""))
            
        with open("elaborated_syllabus_example.md", "w") as f:
            f.write(result.get("elaborated_syllabus_markdown", ""))
            
        print("\n\nSyllabi saved to files: normal_syllabus_example.md and elaborated_syllabus_example.md")
        
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        
if __name__ == "__main__":
    generate_syllabus_example()
