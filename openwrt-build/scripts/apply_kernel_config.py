#!/usr/bin/env python3
"""Apply KEY=VALUE kernel config fragment onto a config file.

- Replaces existing '# CONFIG_KEY is not set' or 'CONFIG_KEY=...' lines.
- Appends missing keys at end of file.
- Skips blank lines and lines starting with '#' that are NOT
  '# CONFIG_' disable markers.
Usage: apply_kernel_config.py <config-file> <fragment.conf>
"""
import sys

cfg_path, frag_path = sys.argv[1], sys.argv[2]

with open(cfg_path) as f:
    lines = f.read().splitlines()

wanted = {}
order = []
for raw in open(frag_path):
    raw = raw.strip()
    if not raw or raw.startswith('#'):
        if raw.startswith('# CONFIG_'):
            pass  # explicit disable marker handled below
        else:
            continue
    if raw.startswith('# CONFIG_') and raw.endswith('is not set'):
        key = raw.split()[1]
        wanted[key] = raw
        order.append(key)
    elif '=' in raw:
        key = raw.split('=', 1)[0]
        wanted[key] = raw
        order.append(key)

out = []
seen = set()
for line in lines:
    s = line.strip()
    hit = None
    if s.startswith('# CONFIG_') and s.endswith('is not set'):
        key = s.split()[1]
        if key in wanted:
            hit = key
    elif s.startswith('CONFIG_') and '=' in s:
        key = s.split('=', 1)[0]
        if key in wanted:
            hit = key
    if hit:
        out.append(wanted[hit])
        seen.add(hit)
    else:
        out.append(line)

for key in order:
    if key not in seen:
        out.append(wanted[key])
        seen.add(key)

with open(cfg_path, 'w') as f:
    f.write('\n'.join(out) + '\n')

print(f'applied {len(seen)} symbols -> {cfg_path}')
