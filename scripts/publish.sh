#!/usr/bin/env bash
# Rebuild webaugur.com search indexes with swish-whee, commit, tag, push (GitHub Pages serves main).
# Usage: scripts/publish.sh [--no-build]
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE="${XPATRIATE_DIR:-$HOME/Documents/Xpatriate}"
SRC="$SITE/www/search/indexes"
if [[ "${1:-}" != "--no-build" ]]; then
  # swish-whee writes slowly on purpose; stay gentle on the disk.
  (cd "$SITE" && nice -n 19 ionice -c3 bin/swhee-index && nice -n 19 ionice -c3 bin/swhee-index-blog)
fi
# Copy index JSON only. 'all' duplicates 'x' and is not in the manifest.
nice -n 19 ionice -c3 rsync -a --delete --exclude=all/ --include='*/' --include='*.json' --exclude='*' "$SRC/" "$REPO_DIR/indexes/"
big=$(find "$REPO_DIR/indexes" -type f -size +19M)
[[ -z "$big" ]] || { echo "Files over jsDelivr 20MB limit:"; echo "$big"; exit 1; }
cd "$REPO_DIR"
git add -A indexes
git diff --cached --quiet && { echo "No index changes."; exit 0; }
git commit -q -m "Rebuild indexes $(date +%F)"
base="v$(date +%Y.%m.%d)"; tag="$base"; n=1
while git rev-parse -q --verify "refs/tags/$tag" >/dev/null || git ls-remote --exit-code --tags origin "$tag" >/dev/null 2>&1; do tag="$base.$n"; n=$((n+1)); done
git tag "$tag"
git push -q origin main "$tag"
curl -fsS "https://purge.jsdelivr.net/gh/webaugur/webaugur-search@main/indexes/manifest.json" >/dev/null || true
echo "Published $tag"
echo "Live in a minute or two at https://webaugur.github.io/webaugur-search/indexes/manifest.json"
