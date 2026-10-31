# webaugur-search

Static [swish-whee](https://github.com/webaugur/swish-whee) search indexes for webaugur.com, served free by jsDelivr from this public repo.

JSON index files only: no media, no post HTML, no images or video. X media always loads from x.com.

## URLs

    https://cdn.jsdelivr.net/gh/webaugur/webaugur-search@<tag>/indexes/manifest.json

Use a tag such as `v2026.10.31` (permanent and immutable). `@main` works too but is cached up to ~12h; purge with
`https://purge.jsdelivr.net/gh/webaugur/webaugur-search@main/<path>`.

jsDelivr limits: 20 MB per file (largest here is ~3.6 MB). Over-limit means it stops serving, never a bill.

## Indexes

`x` (all X posts), year slices `x2012-2020` … `x2026` (used by the year filters in the search UI), `blog`, `dave`, `code`, `photos`, `radio`, `compute`, `words`, `wares`. The `all` index is not published (duplicate of `x`, not in the manifest).

## Rebuild and publish

    scripts/publish.sh            # rebuild in ~/Documents/Xpatriate via bin/swhee-index (nice/ionice), commit, tag vYYYY.MM.DD[.n], push, purge
    scripts/publish.sh --no-build # publish the indexes already built

Then bump the base URL constant in webaugur.com `www/search/search-config.js` to the new tag.
