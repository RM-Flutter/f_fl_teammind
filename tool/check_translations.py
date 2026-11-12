#!/usr/bin/env python3
"""Fails when a .tr() key is missing from en.json / ar.json, or English text is hard-coded in a Text()."""
import json, os, re, sys
root = os.path.join(os.path.dirname(__file__), '..')
en = json.load(open(os.path.join(root, 'assets/json/lang/en.json')))
ar = json.load(open(os.path.join(root, 'assets/json/lang/ar.json')))
consts = {}
for m in re.finditer(r"static const (\w+)\s*=\s*['\"]([^'\"]+)['\"]", open(os.path.join(root, 'lib/core/constants/app_strings.dart')).read()):
    consts[m.group(1)] = m.group(2)
bad = 0
hard = re.compile(r"Text\(\s*(?:const\s*)?['\"]([A-Za-z][^'\"$\n]{2,60})['\"]\s*[,)]")
for d, _, fs in os.walk(os.path.join(root, 'lib')):
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(d, f)
        t = open(p).read()
        t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
        t = re.sub(r'(?m)^\s*//.*$', '', t)
        keys = [consts.get(m.group(1)) for m in re.finditer(r"AppStrings\.(\w+)\.tr\(", t)]
        keys += [m.group(1) for m in re.finditer(r"['\"]([^'\"$\n]{1,80})['\"]\.tr\(", t)]
        for k in filter(None, keys):
            if k not in en or k not in ar:
                print(f"missing key '{k}' ({'en' if k not in en else 'ar'}) in {p}"); bad = 1
        for m in hard.finditer(t):
            if '.tr(' not in t[m.start():m.end() + 8] and not re.fullmatch(r'[a-z, ]+', m.group(1)):
                print(f"hard-coded text '{m.group(1)}' in {p}"); bad = 1
sys.exit(bad)
