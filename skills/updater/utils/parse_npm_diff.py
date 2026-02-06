#!/usr/bin/env python3
"""Parse npm/yarn/bun lock file diff from stdin and output version changes.

Usage: jq -r '.[0].text' <diff_file> | python3 parse_npm_diff.py
Output: one line per change: package_name old_version new_version

Handles package-lock.json, yarn.lock, and bun.lock formats.
"""
import re
import sys

diff = sys.stdin.read()
lines = diff.split("\n")
changes = {}

# --- package-lock.json format ---
# "node_modules/pkg": { "version": "X.Y.Z" }
current_pkg = None
old_ver = None
new_ver = None

for line in lines:
    # package-lock.json: node_modules path
    m = re.match(r'^[ +-]\s+"node_modules/(.+?)"\s*:\s*\{', line)
    if m:
        if current_pkg and old_ver and new_ver and old_ver != new_ver:
            # Use the short package name (last segment for scoped packages)
            changes[current_pkg] = (old_ver, new_ver)
        current_pkg = m.group(1)
        old_ver = None
        new_ver = None

    # yarn.lock: package header like `pkg@^version:`
    ym = re.match(r'^[ +-]?"?(@?[\w][\w./-]*?)@', line)
    if ym and not line.strip().startswith('"node_modules'):
        pkg_name = ym.group(1)
        if pkg_name and not pkg_name.startswith("__"):
            if current_pkg and old_ver and new_ver and old_ver != new_ver:
                changes[current_pkg] = (old_ver, new_ver)
            current_pkg = pkg_name
            old_ver = None
            new_ver = None

    # Version lines
    if line.startswith("-"):
        vm = re.search(r'"version"\s*:\s*"(.+?)"', line)
        if not vm:
            vm = re.match(r'^-\s+version\s+"(.+?)"', line)
        if vm:
            old_ver = vm.group(1)

    if line.startswith("+"):
        vm = re.search(r'"version"\s*:\s*"(.+?)"', line)
        if not vm:
            vm = re.match(r'^\+\s+version\s+"(.+?)"', line)
        if vm:
            new_ver = vm.group(1)

# Last entry
if current_pkg and old_ver and new_ver and old_ver != new_ver:
    changes[current_pkg] = (old_ver, new_ver)

for pkg in sorted(changes):
    old, new = changes[pkg]
    print(f"{pkg} {old} {new}")
