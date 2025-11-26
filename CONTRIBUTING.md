# Contributing

You can add new versions manually, or use one of the helper scripts.

## Manual Updates

1. Add the new version to `[implementation]/versions.txt`.
  * Versions should be listed incrementally.
2. Add new _stable_ versions to `[implementation]/stable.txt`, replacing any previous stable version for that version family.
  * Should only contain the latest stable version for each version family.
3. Append the MD5 checksums for _all_ released files to `[implementation]/checksums.md5`.
4. Append the SHA1 checksums for _all_ released files to `[implementation]/checksums.sha1`.
5. Append the SHA256 checksums for _all_ released files to `[implementation]/checksums.sha256`.
6. Append the SHA512 checksums for _all_ released files to `[implementation]/checksums.sha512`.

* Never remove a version from `versions.txt`.
* Never remove checksums from a `checksum.*` file. Unless the file is literally
  no longer available on the Internet.

## Scripts

### update.sh

The `update.sh` script can be used to add a single new version of a given Ruby implementation. It will download the release artifacts, calculate their checksums, and update the corresponding files.

```bash
# Usage: ./update.sh [implementation] [version]
$ ./update.sh ruby 3.3.10
```

### Automated Syncing (sync_releases.sh)

The `sync_releases.sh` script provides a way to automatically find and add all missing stable releases for implementations that host their releases on GitHub. It currently supports `ruby` and `mruby`.

**Usage:**

To run the script for the default `ruby` implementation:
```bash
$ ./sync_releases.sh
```

You can also provide a supported implementation name as an argument. The script will then fetch releases from that implementation's GitHub repository.
```bash
# Example for mruby
$ ./sync_releases.sh mruby
```

The main `ruby` implementation is synced automatically once a day by the `Sync Ruby Releases` GitHub Action, which will commit any new versions it finds.
