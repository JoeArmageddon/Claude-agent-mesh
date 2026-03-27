#!/usr/bin/env python3
"""Validate that PROTOCOL.md contains all required message types."""

import os
import sys

REQUIRED_MESSAGE_TYPES = [
    "request",
    "response",
    "output",
    "review",
    "reject",
    "approve",
    "revision",
    "escalate",
    "halt",
]

script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(os.path.dirname(script_dir))
protocol_path = os.path.join(repo_root, "protocol", "PROTOCOL.md")

if not os.path.exists(protocol_path):
    print(f"FAIL — protocol/PROTOCOL.md not found at {protocol_path}")
    sys.exit(1)

with open(protocol_path, encoding="utf-8") as f:
    content = f.read()

errors = []
for msg_type in REQUIRED_MESSAGE_TYPES:
    # Check the type appears in the document (as a value, not just any word)
    if f"`{msg_type}`" not in content and f"| {msg_type}" not in content:
        errors.append(f"Message type '{msg_type}' not found in PROTOCOL.md")

if errors:
    print(f"FAIL — {len(errors)} missing message type(s) in PROTOCOL.md:\n")
    for e in errors:
        print(f"  ✗ {e}")
    sys.exit(1)
else:
    print(f"PASS — All {len(REQUIRED_MESSAGE_TYPES)} required message types found in PROTOCOL.md.")
