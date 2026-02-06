#!/usr/bin/env python3
"""Parse uv.lock diff from stdin and output version changes.

Usage: jq -r '.[0].text' <diff_file> | python3 parse_uv_diff.py
Output: one line per change: package_name old_version new_version
"""
import re
import sys

diff = sys.stdin.read()
lines = diff.split("\n")

changes = []
current_pkg = None
old_ver = None
new_ver = None

for line in lines:
    # Context or added line with package name
    if line.startswith(" ") or line.startswith("+"):
        m = re.match(r'^[ +]name = "(.+?)"', line)
        if m:
            # Save previous if we have a version change
            if current_pkg and old_ver and new_ver and old_ver != new_ver:
                changes.append((current_pkg, old_ver, new_ver))
            current_pkg = m.group(1)
            old_ver = None
            new_ver = None

    # Removed version line
    if line.startswith("-"):
        m = re.match(r'^-version = "(.+?)"', line)
        if m:
            old_ver = m.group(1)

    # Added version line
    if line.startswith("+"):
        m = re.match(r'^\+version = "(.+?)"', line)
        if m:
            new_ver = m.group(1)

# Don't forget the last package
if current_pkg and old_ver and new_ver and old_ver != new_ver:
    changes.append((current_pkg, old_ver, new_ver))

for pkg, old, new in sorted(changes):
    print(f"{pkg} {old} {new}")
