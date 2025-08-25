#!/usr/bin/env python3
"""
Launcher script for the language learning app backend.
This script starts the backend server if it's not already running.
"""

import os
import sys
import subprocess
import time
import socket
import platform
import signal

# Configuration
BACKEND_PORT = 8080
BACKEND_HOST = "127.0.0.1"
BACKEND_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "otolingo")

def is_port_in_use(port, host="127.0.0.1"):
    """Check if the given port is already in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex((host, port)) == 0

def start_backend():
    """Start the backend server if it's not already running."""
    if is_port_in_use(BACKEND_PORT, BACKEND_HOST):
        print(f"Backend already running on port {BACKEND_PORT}")
        return True
    
    try:
        print(f"Starting backend server on port {BACKEND_PORT}...")
        
        # Change directory to the backend folder
        os.chdir(BACKEND_DIR)
        
        # Start the backend server
        if platform.system() == "Windows":
            # Hide console window on Windows
            process = subprocess.Popen(
                ["python", "main.py"],
                creationflags=subprocess.CREATE_NEW_CONSOLE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
        else:
            # For Unix-like systems
            process = subprocess.Popen(
                ["python3", "main.py"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                preexec_fn=os.setpgrp
            )
        
        # Wait for the server to start
        for _ in range(10):  # Try for up to 5 seconds
            time.sleep(0.5)
            if is_port_in_use(BACKEND_PORT, BACKEND_HOST):
                print("Backend server started successfully!")
                return True
        
        # If we get here, the server didn't start
        print("Failed to start backend server. Check logs for details.")
        return False
    
    except Exception as e:
        print(f"Error starting backend server: {e}")
        return False

if __name__ == "__main__":
    start_backend()
