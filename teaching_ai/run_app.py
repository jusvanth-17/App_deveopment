#!/usr/bin/env python3
"""
Unified script to run both backend and frontend for the language learning app.
This script will:
1. Start the backend server
2. Launch the Flutter frontend
"""

import os
import sys
import subprocess
import time
import socket
import platform

# Configuration
BACKEND_PORT = 8080
BACKEND_HOST = "127.0.0.1"
BACKEND_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "otolingo")
FLUTTER_CMD = "flutter" if platform.system() == "Windows" else "flutter"

def is_port_in_use(port, host="127.0.0.1"):
    """Check if the given port is already in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex((host, port)) == 0

def kill_process_on_port(port):
    """Kill any process running on the specified port."""
    try:
        if platform.system() == "Windows":
            result = subprocess.run(
                f"netstat -ano | findstr :{port}", 
                shell=True, 
                capture_output=True, 
                text=True
            )
            if result.stdout:
                for line in result.stdout.splitlines():
                    if f":{port}" in line and "LISTENING" in line:
                        pid = line.strip().split()[-1]
                        subprocess.run(f"taskkill /F /PID {pid}", shell=True)
                        print(f"Killed process {pid} that was using port {port}")
        else:  # Unix-like
            result = subprocess.run(
                f"lsof -i :{port} -t", 
                shell=True, 
                capture_output=True, 
                text=True
            )
            if result.stdout:
                pid = result.stdout.strip()
                subprocess.run(f"kill -9 {pid}", shell=True)
                print(f"Killed process {pid} that was using port {port}")
    except Exception as e:
        print(f"Error killing process on port {port}: {e}")

def start_backend():
    """Start the backend server if it's not already running."""
    if is_port_in_use(BACKEND_PORT, BACKEND_HOST):
        print(f"Port {BACKEND_PORT} already in use. Stopping the process...")
        kill_process_on_port(BACKEND_PORT)
        time.sleep(1)
    
    try:
        print(f"Starting backend server on port {BACKEND_PORT}...")
        
        # Save the current directory to return to it later
        original_dir = os.getcwd()
        os.chdir(BACKEND_DIR)
        
        # Add more debug info
        print(f"Backend directory: {BACKEND_DIR}")
        print(f"Current working directory: {os.getcwd()}")
        
        # Pass environment variables explicitly from .env file
        env_path = os.path.join(BACKEND_DIR, ".env")
        env_vars = {}
        
        if os.path.exists(env_path):
            print(f"Loading environment variables from {env_path}")
            with open(env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip().strip('"\'')
        
        # Merge with existing environment
        process_env = os.environ.copy()
        process_env.update(env_vars)
        
        # Create log files
        stdout_log = open(os.path.join(BACKEND_DIR, "backend_stdout.log"), "w")
        stderr_log = open(os.path.join(BACKEND_DIR, "backend_stderr.log"), "w")
        
        if platform.system() == "Windows":
            process = subprocess.Popen(
                ["python", "main.py"],
                creationflags=subprocess.CREATE_NEW_CONSOLE,
                stdout=stdout_log,
                stderr=stderr_log,
                env=process_env
            )
        else:
            process = subprocess.Popen(
                ["python3", "main.py"],
                stdout=stdout_log,
                stderr=stderr_log,
                env=process_env
            )
        
        # Wait longer for the server to start
        print("Waiting for backend server to start...")
        for i in range(20):  # Increased from 10 to 20 attempts
            time.sleep(1)  # Increased from 0.5 to 1 second
            if is_port_in_use(BACKEND_PORT, BACKEND_HOST):
                print("✅ Backend server started successfully!")
                # Return to the original directory
                os.chdir(original_dir)
                return True
            print(f"Checking if server is up (attempt {i+1}/20)...")
        
        # Try to get error output if server failed
        try:
            # Close the log files
            stdout_log.close()
            stderr_log.close()
            
            # Read the logs
            with open(os.path.join(BACKEND_DIR, "backend_stdout.log"), "r") as f:
                stdout_content = f.read()
            with open(os.path.join(BACKEND_DIR, "backend_stderr.log"), "r") as f:
                stderr_content = f.read()
                
            print("Backend server stdout output:")
            print(stdout_content)
            print("\nBackend server stderr output:")
            print(stderr_content)
            
            # Try to terminate the process if it's still running
            process.terminate()
        except Exception as e:
            print(f"Error reading logs: {e}")
            
        print("❌ Failed to start backend server. Check logs for details.")
        # Return to the original directory
        os.chdir(original_dir)
        return False
    
    except Exception as e:
        print(f"Error starting backend server: {e}")
        # Make sure we always return to the original directory
        if 'original_dir' in locals():
            os.chdir(original_dir)
        return False

def start_flutter_app():
    """Start the Flutter application on a single device."""
    try:
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        print("Starting Flutter application...")

        flutter_cmd = [FLUTTER_CMD, "run"]

        if len(sys.argv) > 1:
            # Use the device passed as an argument
            flutter_cmd.extend(["-d", sys.argv[1]])
        else:
            try:
                result = subprocess.run(
                    [FLUTTER_CMD, "devices", "--machine"],
                    capture_output=True,
                    text=True,
                    check=True
                )
                import json
                devices = json.loads(result.stdout)
                if devices:
                    default_device = devices[0]["id"]
                    print(f"Using default device: {default_device}")
                    flutter_cmd.extend(["-d", default_device])
                else:
                    print("❌ No Flutter devices found. Please connect a device or start a simulator.")
                    return False
            except Exception as e:
                print(f"Error detecting Flutter devices: {e}")
                return False
        
        # Run foreground so you can use hot reload/restart
        subprocess.run(flutter_cmd)
        return True

    except Exception as e:
        print(f"Error starting Flutter app: {e}")
        return False

def main():
    print("=== Starting Language Learning App ===")
    
    backend_success = start_backend()
    if not backend_success:
        print("Backend failed. Exiting.")
        return
    
    flutter_success = start_flutter_app()
    if not flutter_success:
        print("Flutter app failed.")

if __name__ == "__main__":
    main()
