#!/usr/bin/env bash
set -Eeuo pipefail

LICENSE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALLER="$LICENSE_DIR/install"
DEFAULT_SOURCE_REF=747531b2acc027b7308a27722efb2dc6d43377db
TEST_SOURCE_REF=0123456789abcdef0123456789abcdef01234567
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/ory-ci-license-tests.XXXXXX")

cleanup() {
	rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

assert_file_equals() {
	expected=$1
	actual=$2
	cmp -s "$expected" "$actual" || fail "$actual does not match $expected"
}

file_mode() {
	file=$1
	if stat -c '%a' "$file" >/dev/null 2>&1; then
		stat -c '%a' "$file"
	else
		stat -f '%Lp' "$file"
	fi
}

assert_mode() {
	expected=$1
	file=$2
	actual=$(file_mode "$file")
	[ "$actual" = "$expected" ] || fail "$file mode is $actual, expected $expected"
}

assert_core_install() {
	target=$1
	for asset in license-engine.sh licenses list-licenses; do
		assert_file_equals "$LICENSE_DIR/$asset" "$target/.bin/$asset"
		assert_mode 755 "$target/.bin/$asset"
	done
}

assert_all_assets() {
	target=$1
	assert_core_install "$target"
	for asset in license-template-go.tpl license-template-node.json; do
		assert_file_equals "$LICENSE_DIR/$asset" "$target/.bin/$asset"
		assert_mode 644 "$target/.bin/$asset"
	done
}

make_fake_go() {
	bin_dir=$1
	mkdir -p "$bin_dir"
	cat >"$bin_dir/go" <<'EOF'
#!/bin/sh
set -e
[ "$1" = install ]
mkdir -p "$GOBIN"
: >"$GOBIN/go-licenses"
chmod 0755 "$GOBIN/go-licenses"
EOF
	chmod +x "$bin_dir/go"
}

make_fake_curl() {
	bin_dir=$1
	mkdir -p "$bin_dir"
	cat >"$bin_dir/curl" <<'EOF'
#!/bin/sh
set -e

url=
destination=
while [ "$#" -gt 0 ]; do
	case "$1" in
	https://*) url=$1 ;;
	-o)
		shift
		destination=$1
		;;
	esac
	shift
done

[ -n "$url" ] && [ -n "$destination" ]
case "$url" in
*"/${EXPECTED_REF}/licenses/"*) ;;
*)
	echo "unexpected URL: $url" >&2
	exit 91
	;;
esac

asset=${url##*/}
printf '%s\n' "$url" >>"$CURL_LOG"
[ "${FAIL_DOWNLOAD_ASSET:-}" != "$asset" ] || exit 92
cp "$TEST_SOURCE_DIR/$asset" "$destination"
if [ "${CORRUPT_ASSET:-}" = "$asset" ]; then
	printf 'corrupt\n' >>"$destination"
fi
EOF
	chmod +x "$bin_dir/curl"
}

seed_existing_core_assets() {
	target=$1
	mkdir -p "$target/.bin"
	for asset in license-engine.sh licenses list-licenses; do
		printf 'existing-%s\n' "$asset" >"$target/.bin/$asset"
	done
}

assert_existing_core_assets() {
	target=$1
	for asset in license-engine.sh licenses list-licenses; do
		expected="existing-$asset"
		actual=$(sed -n '1p' "$target/.bin/$asset")
		[ "$actual" = "$expected" ] || fail "$asset changed after a failed install"
	done
}

run_local_source_test() {
	target="$TEST_ROOT/local-source"
	fake_bin="$TEST_ROOT/local-source-bin"
	mkdir -p "$target"
	make_fake_go "$fake_bin"
	(
		cd "$target"
		PATH="$fake_bin:$PATH" "$INSTALLER" --full-install --source-dir "$LICENSE_DIR" >/dev/null
	)
	assert_all_assets "$target"
}

run_source_ref_test() {
	target="$TEST_ROOT/source-ref"
	fake_bin="$TEST_ROOT/source-ref-bin"
	curl_log="$TEST_ROOT/source-ref-curl.log"
	mkdir -p "$target"
	make_fake_curl "$fake_bin"
	: >"$curl_log"
	(
		cd "$target"
		EXPECTED_REF="$TEST_SOURCE_REF" \
			TEST_SOURCE_DIR="$LICENSE_DIR" \
			CURL_LOG="$curl_log" \
			PATH="$fake_bin:$PATH" \
			"$INSTALLER" --source-ref "$TEST_SOURCE_REF" >/dev/null
	)
	assert_core_install "$target"
	[ "$(wc -l <"$curl_log" | tr -d ' ')" = 4 ] || fail "source-ref mode made an unexpected number of downloads"
	grep -F "/$TEST_SOURCE_REF/licenses/checksums.sha256" "$curl_log" >/dev/null || fail "source-ref manifest URL was not immutable"
}

run_default_source_test() {
	target="$TEST_ROOT/default-source"
	fake_bin="$TEST_ROOT/default-source-bin"
	curl_log="$TEST_ROOT/default-source-curl.log"
	mkdir -p "$target"
	make_fake_curl "$fake_bin"
	: >"$curl_log"
	(
		cd "$target"
		EXPECTED_REF="$DEFAULT_SOURCE_REF" \
			TEST_SOURCE_DIR="$LICENSE_DIR" \
			CURL_LOG="$curl_log" \
			PATH="$fake_bin:$PATH" \
			"$INSTALLER" >/dev/null
	)
	assert_core_install "$target"
	[ "$(wc -l <"$curl_log" | tr -d ' ')" = 3 ] || fail "default mode did not preserve its three asset downloads"
	if grep -F 'checksums.sha256' "$curl_log" >/dev/null; then
		fail "default mode unexpectedly downloaded a manifest absent from its pinned revision"
	fi
}

run_argument_validation_test() {
	target="$TEST_ROOT/arguments"
	fake_bin="$TEST_ROOT/arguments-bin"
	curl_marker="$TEST_ROOT/curl-called"
	mkdir -p "$target" "$fake_bin"
	cat >"$fake_bin/curl" <<EOF
#!/bin/sh
touch "$curl_marker"
exit 99
EOF
	chmod +x "$fake_bin/curl"

	assert_invalid() {
		rm -f "$curl_marker"
		if (
			cd "$target"
			PATH="$fake_bin:$PATH" "$INSTALLER" "$@" >/dev/null 2>&1
		); then
			fail "invalid arguments succeeded: $*"
		fi
		[ ! -e "$curl_marker" ] || fail "invalid arguments reached the downloader: $*"
	}

	assert_invalid --source-ref
	assert_invalid --source-ref abc123
	assert_invalid --source-ref zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
	assert_invalid --source-dir
	assert_invalid --source-dir "$LICENSE_DIR" --source-ref "$TEST_SOURCE_REF"
	assert_invalid --source-ref "$TEST_SOURCE_REF" --source-ref "$TEST_SOURCE_REF"
	assert_invalid --unknown
}

run_local_checksum_failure_test() {
	target="$TEST_ROOT/local-checksum-failure"
	source_dir="$TEST_ROOT/corrupt-source"
	mkdir -p "$target" "$source_dir"
	for asset in checksums.sha256 license-engine.sh licenses list-licenses license-template-go.tpl license-template-node.json; do
		cp "$LICENSE_DIR/$asset" "$source_dir/$asset"
	done
	printf 'corrupt\n' >>"$source_dir/licenses"
	seed_existing_core_assets "$target"
	if (
		cd "$target"
		"$INSTALLER" --source-dir "$source_dir" >/dev/null 2>&1
	); then
		fail "corrupt local asset passed checksum verification"
	fi
	assert_existing_core_assets "$target"
}

run_remote_failure_tests() {
	fake_bin="$TEST_ROOT/remote-failure-bin"
	make_fake_curl "$fake_bin"

	for failure_mode in checksum download; do
		target="$TEST_ROOT/remote-$failure_mode-failure"
		curl_log="$TEST_ROOT/remote-$failure_mode-curl.log"
		mkdir -p "$target"
		seed_existing_core_assets "$target"
		: >"$curl_log"

		failure_env=()
		if [ "$failure_mode" = checksum ]; then
			failure_env=(CORRUPT_ASSET=licenses)
		else
			failure_env=(FAIL_DOWNLOAD_ASSET=licenses)
		fi

		if (
			cd "$target"
			env \
				EXPECTED_REF="$TEST_SOURCE_REF" \
				TEST_SOURCE_DIR="$LICENSE_DIR" \
				CURL_LOG="$curl_log" \
				PATH="$fake_bin:$PATH" \
				"${failure_env[@]}" \
				"$INSTALLER" --source-ref "$TEST_SOURCE_REF" >/dev/null 2>&1
		); then
			fail "remote $failure_mode failure unexpectedly succeeded"
		fi
		assert_existing_core_assets "$target"
	done
}

run_installation_failure_test() {
	target="$TEST_ROOT/installation-failure"
	fake_bin="$TEST_ROOT/installation-failure-bin"
	mv_marker="$TEST_ROOT/mv-failed"
	real_mv=$(command -v mv)
	mkdir -p "$target" "$fake_bin"
	seed_existing_core_assets "$target"
	cat >"$fake_bin/mv" <<'EOF'
#!/bin/sh
set -e
destination=$3
if [ ! -e "$MV_FAIL_MARKER" ] && [ "$destination" = .bin/licenses ]; then
	touch "$MV_FAIL_MARKER"
	exit 93
fi
exec "$REAL_MV" "$@"
EOF
	chmod +x "$fake_bin/mv"

	if (
		cd "$target"
		MV_FAIL_MARKER="$mv_marker" \
			REAL_MV="$real_mv" \
			PATH="$fake_bin:$PATH" \
			"$INSTALLER" --source-dir "$LICENSE_DIR" >/dev/null 2>&1
	); then
		fail "installation failure unexpectedly succeeded"
	fi
	[ -e "$mv_marker" ] || fail "installation failure was not exercised"
	assert_existing_core_assets "$target"
	if find "$target/.bin" -name '*.tmp.*' -print | grep . >/dev/null; then
		fail "installation failure left prepared files behind"
	fi
}

make_isolated_tool_path() {
	bin_dir=$1
	shift
	mkdir -p "$bin_dir"
	for tool in "$@"; do
		tool_path=$(command -v "$tool") || fail "required test tool not found: $tool"
		ln -s "$tool_path" "$bin_dir/$tool"
	done
}

run_checksum_backend_tests() {
	for backend in shasum openssl; do
		target="$TEST_ROOT/checksum-$backend"
		tool_bin="$TEST_ROOT/checksum-$backend-bin"
		mkdir -p "$target"
		make_isolated_tool_path "$tool_bin" awk install mkdir mktemp mv rm "$backend"
		(
			cd "$target"
			PATH="$tool_bin" /bin/sh "$INSTALLER" --source-dir "$LICENSE_DIR" >/dev/null
		)
		assert_core_install "$target"
	done

	empty_bin="$TEST_ROOT/no-checksum-bin"
	mkdir -p "$empty_bin"
	if PATH="$empty_bin" /bin/sh "$INSTALLER" --source-dir "$LICENSE_DIR" >"$TEST_ROOT/no-checksum.log" 2>&1; then
		fail "installer succeeded without a SHA-256 backend"
	fi
	grep -F 'a SHA-256 implementation is required' "$TEST_ROOT/no-checksum.log" >/dev/null || fail "missing checksum backend error was unclear"
}

run_license_behavior_tests() {
	printf '"example","MIT"\n' | "$LICENSE_DIR/license-engine.sh" >"$TEST_ROOT/allowed-license.log"
	grep -F 'Licenses are okay.' "$TEST_ROOT/allowed-license.log" >/dev/null || fail "allowed license was rejected"

	printf '"github.com/ory-corp/cloud/service","Proprietary"\n' |
		"$LICENSE_DIR/license-engine.sh" >"$TEST_ROOT/approved-module.log"
	grep -F 'Licenses are okay.' "$TEST_ROOT/approved-module.log" >/dev/null || fail "approved module was rejected"

	if printf '"example","GPL-3.0"\n' | "$LICENSE_DIR/license-engine.sh" >"$TEST_ROOT/unknown-license.log" 2>&1; then
		fail "unknown license was accepted"
	fi
	grep -F 'Unknown licenses found!' "$TEST_ROOT/unknown-license.log" >/dev/null || fail "unknown license failure was unclear"
	grep -F '"example","GPL-3.0"' "$TEST_ROOT/unknown-license.log" >/dev/null || fail "unknown license details were omitted"
}

run_action_hardening_tests() {
	uses_count=0
	while IFS= read -r line; do
		uses_count=$((uses_count + 1))
		ref=${line##*@}
		ref=${ref%% *}
		[[ "$ref" =~ ^[0-9a-f]{40}$ ]] || fail "mutable nested action reference: $line"
	done < <(grep -hE '^[[:space:]]*(-[[:space:]]+)?uses:' "$LICENSE_DIR"/*/action.yml)
	[ "$uses_count" -gt 0 ] || fail "no nested license actions were checked"

	for action in "$LICENSE_DIR/check/action.yml" "$LICENSE_DIR/setup/action.yml"; do
		grep -F 'GITHUB_ACTION_PATH' "$action" >/dev/null || fail "$action does not use GITHUB_ACTION_PATH"
		grep -F -- '--source-dir' "$action" >/dev/null || fail "$action does not select its bundled source directory"
		if grep -E 'ORY_CI_(ROOT|REF)|raw\.githubusercontent\.com' "$action" >/dev/null; then
			fail "$action still uses an ambient or remote installer source"
		fi
	done
}

run_local_source_test
run_source_ref_test
run_default_source_test
run_argument_validation_test
run_local_checksum_failure_test
run_remote_failure_tests
run_installation_failure_test
run_checksum_backend_tests
run_license_behavior_tests
run_action_hardening_tests

echo "All license tests passed."
