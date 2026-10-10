#!/usr/bin/env bash
set -euo pipefail

# Lists non-dev packages whose resolved version in package-lock.json differs
# from <base-ref>. Empty output means only dev tooling changed.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <base-ref>" >&2
  exit 1
fi

base_ref=$1

git show "${base_ref}:package-lock.json" | node -e '
const fs = require("fs");
const before = JSON.parse(fs.readFileSync(0, "utf8")).packages || {};
const after = JSON.parse(fs.readFileSync("package-lock.json", "utf8")).packages || {};

for (const path of new Set([...Object.keys(before), ...Object.keys(after)])) {
  if (!path) continue;
  const a = before[path];
  const b = after[path];
  if ((a ? a.dev : true) && (b ? b.dev : true)) continue;
  if ((a && a.version) === (b && b.version)) continue;
  const name = path.replace(/^.*node_modules\//, "");
  console.log(`${name}: ${a ? a.version : "(none)"} -> ${b ? b.version : "(removed)"}`);
}
'
