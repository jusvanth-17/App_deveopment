import os
import sys

TESTS_DIR = os.path.dirname(__file__)
BACKEND_ROOT = os.path.abspath(os.path.join(TESTS_DIR, ".."))
if BACKEND_ROOT not in sys.path:
	sys.path.insert(0, BACKEND_ROOT)