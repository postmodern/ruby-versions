# ruby-versions

A common repository of ruby version metadata.

## Directory Structure

* `[ruby]/`
  * `versions.txt` - an exhaustive list of every released version.
    Versions must be listed in natural order.
  * `stable.txt` - a list of current stable versions.
    Versions must be listed in natural order.
  * `checksums.md5` - a `md5sum` compatible list of MD5 checksums of every
    released file.
  * `checksums.sha1` - a `sha1sum` compatible list of SHA1 checksums of every
    released file.
  * `checksums.sha256` - a `sha256sum` compatible list of SHA256 checksums of every
    released file.
  * `checksums.sha512` - a `sha512sum` compatible list of SHA512 checksums of every
    released file.

## Contributing

1. Add the new version to `versions.txt`.
2. Replace the previous version in `stable.txt` with the new version.
3. Append the MD5 checksums for _all_ released files to `checksums.md5`.
4. Append the SHA1 checksums for _all_ released files to `checksums.sha1`.
5. Append the SHA256 checksums for _all_ released files to `checksums.sha256`.
6. Append the SHA512 checksums for _all_ released files to `checksums.sha512`.
