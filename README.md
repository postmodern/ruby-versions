# ruby-versions

A common repository of ruby version metadata.

## Directory Structure

* `[ruby]`
  * `versions.txt` - an exhaustive list of every version. Versions must be
    listed in natural order.
  * `stable.txt` - a list of current stable versions. Versions must be listed
    in natural order.
  * `checksums.md5` - a `md5sum` compatible list of MD5 checksums of every
    released file.
  * `checksums.sha1` - a `sha1sum` compatible list of SHA1 checksums of every
    released file.

## Contributing

1. Add the new version to `versions.txt`.
2. Replace the previous version in `stable.txt` with the new version.
3. Add MD5 checksums for all released files to `checksums.md5`.
4. Add SHA1 checksums for all released files to `checksums.sha1`.
