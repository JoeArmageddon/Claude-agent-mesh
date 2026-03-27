#!/usr/bin/env python3
"""Validate all AGENT.md files in the agents/ and core/ directories."""

import os
import sys
import re

REQUIRED_FRONTMATTER = ["agent", "role", "token-budget"]
REQUIRED_SECTIONS = ["## Identity", "## Expertise", "## Output format", "## Hard rules"]
STATUS_PATTERN = re.compile(r"^## Status:", re.MULTILINE)
FRONTMATTER_PATTERN = re.compile(r"^---\n(.*?)\n---", re.DOTALL)

errors = []
checked = 0


def check_agent(path):
    global checked
    checked += 1
    with open(path, encoding="utf-8") as f:
        content = f.read()

    # Check frontmatter
    fm_match = FRONTMATTER_PATTERN.match(content)
    if not fm_match:
        errors.append(f"{path}: Missing YAML frontmatter block")
        return

    fm = fm_match.group(1)
    for field in REQUIRED_FRONTMATTER:
        if not re.search(rf"^{field}:", fm, re.MULTILINE):
            errors.append(f"{path}: Missing frontmatter field '{field}'")

    # Check required sections
    for section in REQUIRED_SECTIONS:
        if section not in content:
            errors.append(f"{path}: Missing section '{section}'")

    # Check Status line in output format section
    if "## Output format" in content:
        output_section_start = content.index("## Output format")
        output_section = content[output_section_start:]
        if not STATUS_PATTERN.search(output_section):
            errors.append(f"{path}: Output format section missing '## Status:' line")


def walk_agents(root):
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            if filename == "AGENT.md":
                yield os.path.join(dirpath, filename)


# Find repo root (script is in .github/scripts/)
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(os.path.dirname(script_dir))

for search_dir in ["agents", "core"]:
    full_path = os.path.join(repo_root, search_dir)
    if os.path.isdir(full_path):
        for agent_path in walk_agents(full_path):
            check_agent(agent_path)

if errors:
    print(f"FAIL — {len(errors)} error(s) found across {checked} AGENT.md files:\n")
    for e in errors:
        print(f"  ✗ {e}")
    sys.exit(1)
else:
    print(f"PASS — {checked} AGENT.md files validated successfully.")
