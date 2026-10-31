#!/usr/bin/env bash
# Rebuild webaugur.com search indexes with swish-whee, commit, tag, push (GitHub Pages serves main).
# Usage: scripts/publish.sh [--no-build]
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE="${XPATRIATE_DIR:-$HOME/Documents/Xpatriate}"
SRC="$SITE/www/search/indexes"
if [[ "${1:-}" != "--no-build" ]]; then
  # swish-whee writes slowly on purpose; stay gentle on the disk.
  (cd "$SITE" && SWHEE_SRC="${SWHEE_SRC:-$HOME/Documents/swish-whee}" nice -n 19 ionice -c3 bin/swhee-index && { [[ ! -x bin/swhee-index-blog ]] || nice -n 19 ionice -c3 bin/swhee-index-blog; })
fi
# Copy index JSON only. 'all' duplicates 'x' and is not in the manifest.
nice -n 19 ionice -c3 rsync -a --delete --exclude=all/ --include='*/' --include='*.json' --exclude='*' "$SRC/" "$REPO_DIR/indexes/"
# Tell the browser which indexes are one flat index.json, so it never
# requests a missing index.json for sharded ones (a 404 per search).
python3 - "$REPO_DIR/indexes" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]); p = root / "manifest.json"
man = json.loads(p.read_text(encoding="utf-8"))
for e in man.get("indexes", []):
    d = root / (e.get("path") or e["name"] + "/")
    e["flat"] = (d / "index.json").is_file()
p.write_text(json.dumps(man, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
PY
# X catalog for webaugur.com/x/ and "More like…" (text + X links only, no media).
CODE="${XPATRIATE_CODE:-$SITE}"
PYTHONPATH="$CODE" nice -n 19 ionice -c3 python3 -m xpatriate.xcatalog "$SITE/www/x" "$REPO_DIR/x"
big=$(find "$REPO_DIR/indexes" -type f -size +19M)
[[ -z "$big" ]] || { echo "Files over 20MB:"; echo "$big"; exit 1; }
cd "$REPO_DIR"
git add -A indexes x
git diff --cached --quiet && { echo "No index changes."; exit 0; }
git commit -q -m "Rebuild indexes $(date +%F)"
base="v$(date +%Y.%m.%d)"; tag="$base"; n=1
while git rev-parse -q --verify "refs/tags/$tag" >/dev/null || git ls-remote --exit-code --tags origin "$tag" >/dev/null 2>&1; do tag="$base.$n"; n=$((n+1)); done
git tag "$tag"
git push -q origin main "$tag"
curl -fsS "https://purge.jsdelivr.net/gh/webaugur/webaugur-search@main/indexes/manifest.json" >/dev/null || true
echo "Published $tag"
echo "Live in a minute or two at https://webaugur.github.io/webaugur-search/indexes/manifest.json"
