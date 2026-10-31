# webaugur-search

Static [swish-whee](https://github.com/webaugur/swish-whee) search indexes for webaugur.com, served free by GitHub Pages from this public repo.

JSON index files only: no media, no post HTML, no images or video. X media always loads from x.com.

## URLs

Live (GitHub Pages, main branch, open CORS, gzip):

    https://webaugur.github.io/webaugur-search/indexes/manifest.json

Every publish is also a tagged commit (`v2026.10.31`, `v2026.11.02`, ...), so old versions stay in git history.

jsDelivr (`https://cdn.jsdelivr.net/gh/webaugur/webaugur-search@<tag>/indexes/...`) does **not** work reliably here:
for GitHub repos over 50 MB it answers browser requests (which ask for brotli) with
`403 Package size exceeded the configured limit of 50 MB`. The indexes are ~230 MB raw.
It would only work if the indexes were split across several repos under 50 MB each.

Limits either way are free with no billing: GitHub Pages 1 GB site / ~100 GB a month soft bandwidth (throttles, never charges).

## Indexes

`x` (all X posts), year slices `x2012-2020` … `x2026` (used by the year filters in the search UI), `blog`, `dave`, `code`, `photos`, `radio`, `compute`, `words`, `wares`. The `all` index is not published (duplicate of `x`, not in the manifest).

## Rebuild and publish

    scripts/publish.sh            # rebuild in ~/Documents/Xpatriate via bin/swhee-index (nice/ionice), commit, tag vYYYY.MM.DD[.n], push, purge
    scripts/publish.sh --no-build # publish the indexes already built

GitHub Pages picks up `main` within a minute or two; no change is needed on webaugur.com. The base URL lives in webaugur.com `www/search/search-config.js`.
