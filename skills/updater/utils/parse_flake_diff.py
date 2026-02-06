#!/usr/bin/env python3
"""Parse flake.lock diff from stdin and output input rev changes.

Usage: jq -r '.[0].text' <diff_file> | python3 parse_flake_diff.py
Output: one line per change: input_name old_rev new_rev source_url
"""
import json
import re
import sys

diff = sys.stdin.read()
lines = diff.split("\n")

# Track current node name and collect rev changes
current_node = None
old_rev = None
new_rev = None
changes = []

# Also try to extract the source owner/repo for each node
node_sources = {}

for i, line in enumerate(lines):
    # Detect node name from JSON structure: "node-name": {
    m = re.match(r'^[ +-]\s+"(\w[\w-]*)"\s*:\s*\{', line)
    if m:
        # Save previous
        if current_node and old_rev and new_rev and old_rev != new_rev:
            changes.append((current_node, old_rev, new_rev))
        current_node = m.group(1)
        old_rev = None
        new_rev = None

    # Extract owner/repo from "original" blocks
    if current_node:
        owner_match = re.search(r'"owner"\s*:\s*"(.+?)"', line)
        repo_match = re.search(r'"repo"\s*:\s*"(.+?)"', line)
        if owner_match:
            node_sources.setdefault(current_node, {})["owner"] = owner_match.group(1)
        if repo_match:
            node_sources.setdefault(current_node, {})["repo"] = repo_match.group(1)

    # Removed rev
    if line.startswith("-"):
        m = re.search(r'"rev"\s*:\s*"([a-f0-9]+)"', line)
        if m:
            old_rev = m.group(1)

    # Added rev
    if line.startswith("+"):
        m = re.search(r'"rev"\s*:\s*"([a-f0-9]+)"', line)
        if m:
            new_rev = m.group(1)

# Don't forget the last
if current_node and old_rev and new_rev and old_rev != new_rev:
    changes.append((current_node, old_rev, new_rev))

# Filter out non-input nodes (like "root")
changes = [(n, o, r) for n, o, r in changes if n != "root"]

for name, old, new in sorted(changes):
    src = node_sources.get(name, {})
    owner = src.get("owner", "")
    repo = src.get("repo", "")
    if owner and repo:
        url = f"https://github.com/{owner}/{repo}/compare/{old[:12]}...{new[:12]}"
        print(f"{name} {old[:12]} {new[:12]} {url}")
    else:
        print(f"{name} {old[:12]} {new[:12]}")
