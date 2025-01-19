#!/usr/bin/env bash

set -e

if [[ $# -lt 2 ]]; then
	echo "usage: $0 [ruby|mruby|jruby|rubinius|truffleruby|truffleruby-graalvm] [VERSION] [RELEASE_DIRECTORY]"
	exit 1
fi

ruby="$1"
version="$2"
dest="${3:-pkg}"

case "$ruby" in
	ruby)
		version_major="${version:0:1}"
		version_family="${version:0:3}"

		if [[ "$version_major" == "2" ]]; then
			exts=(tar.bz2 tar.gz tar.xz zip)
		else
			exts=(tar.gz tar.xz zip)
		fi

		downloads_url="https://cache.ruby-lang.org/pub/ruby"
		;;
	mruby)
		exts=(tar.gz zip)
		downloads_url="https://github.com/mruby/mruby/archive"
		;;
	jruby)
		exts=(tar.gz zip)
		downloads_url="https://repo1.maven.org/maven2/org/jruby/jruby-dist"
		;;
	rubinius)
		exts=(tar.bz2)
		downloads_url="https://rubinius-releases-rubinius-com.s3.amazonaws.com"
		;;
	truffleruby|truffleruby-graalvm)
		exts=(linux-amd64 linux-aarch64 macos-amd64 macos-aarch64)
		downloads_url="https://github.com/oracle/truffleruby/releases/download"
		;;
	*)
		echo "$0: unknown ruby: $ruby" >&2
		exit 1
		;;
esac

mkdir -p "$dest"

for ext in "${exts[@]}"; do
	case "$ruby" in
		ruby)
			archive="ruby-${version}.${ext}"
			url="$downloads_url/$version_family/$archive"
			;;
		mruby)
			archive="mruby-${version}.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		jruby)
			archive="jruby-dist-${version}-bin.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		rubinius)
			archive="rubinius-${version}.${ext}"
			url="$downloads_url/$archive"
			;;
		truffleruby)
			archive="truffleruby-${version}-${ext}.tar.gz"
			url="$downloads_url/graal-$version/$archive"
			;;
		truffleruby-graalvm)
			archive="truffleruby-jvm-${version}-${ext}.tar.gz"
			url="$downloads_url/graal-$version/$archive"
			;;
	esac

	cwd=$(pwd)
	pushd "$dest" >/dev/null
	if [ -s "$archive" ]; then
		echo "Already downloaded $archive"
	else
		wget -O "$archive" "$url"
	fi

	for algorithm in md5 sha1 sha256 sha512; do
		# 1) Append the new checksum line
		"${algorithm}sum" "$archive" >> "$cwd/$ruby/checksums.$algorithm"

		# 2) Remove duplicates (keeping the first occurrence) without sorting
		awk '!seen[$0]++' "$cwd/$ruby/checksums.$algorithm" \
			> "$cwd/$ruby/checksums.$algorithm.tmp"

		mv "$cwd/$ruby/checksums.$algorithm.tmp" "$cwd/$ruby/checksums.$algorithm"
	done
	popd >/dev/null
done

# This script appends a new version to versions.txt and ensures it remains sorted.
# Steps:
# 1. Append the new version to versions.txt.
# 2. Temporarily transform stable versions (those with no dash, e.g., "3.0.0")
#    by appending "-zzzzzz". This ensures they sort *after* any lines containing
#    suffixes like "-preview", "-rc", or "-pXYZ".
# 3. Sort the file uniquely (-u) with "-" as the field separator (-t-):
#    -k1,1V sorts the main version (e.g., "3.0.0") as a version,
#    -k2,2V sorts suffixes (e.g., "preview1", "rc2") as versions,
#    so the transformed stable lines appear last in their version group.
# 4. Remove the temporary "-zzzzzz" suffix from stable versions.
# 5. Replace the original file with the sorted result.
echo "$version" >> "$ruby/versions.txt"
sed 's/^\([0-9][^-]*\)$/\1-zzzzzz/' "$ruby/versions.txt" \
| sort -u -t- -k1,1V -k2,2V \
| sed 's/-zzzzzz$//' \
> "$ruby/versions.txt.tmp"
mv "$ruby/versions.txt.tmp" "$ruby/versions.txt"

if [[ -f "$ruby/stable.txt" ]]; then
	stable_file="$ruby/stable.txt"
	version_family="${version%.*}" # Extract major.minor from version (e.g., 3.3)

	# Use sed to replace the version for the major.minor family or append it if not found
	if grep -qE "^${version_family}\." "$stable_file"; then
		sed -i '' -E "s/^(${version_family}\.).*/$version/" "$stable_file"
		echo "Updated $stable_file to $version"
	else
		echo "$version" >> "$stable_file"
		echo "Appended $version to $stable_file"
	fi

	# Sort and remove duplicates
	sort -u -o "$stable_file" "$stable_file"
else
	echo "$version" > "$ruby/stable.txt"
	echo "Created $ruby/stable.txt with $version."
fi
