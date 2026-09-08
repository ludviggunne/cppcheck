#! /usr/bin/env bash

[ -z "$CPPCHECK" ] && CPPCHECK="$(dirname "${BASH_SORCE[0]}")"/cppcheck

failed=no
temp_c_1="$(mktemp XXX.c)"

strace_test() {
	local command="$1"
	local pattern="$2"
	local expected="$3"
	local actual="$(strace --follow-forks $command 2>&1 | grep "$pattern" | wc --lines)"

	if [ ! "$expected" = "$actual" ]; then
		>&2 echo "Command '$command' performed $actual syscalls matching pattern '$pattern', but $expected was expected"
		failed=yes
	fi
}

cat <<-EOF >"$temp_c_1"
void f(int x) {
  int a = x / 0;
}
EOF

strace_test "$CPPCHECK $temp_c_1"                    "openat.*$temp_c_1" 2
strace_test "$CPPCHECK $temp_c_1 --suppress=zerodiv" "openat.*$temp_c_1" 1
strace_test "$CPPCHECK $temp_c_1 --format=xml"       "openat.*$temp_c_1" 1
strace_test "$CPPCHECK $temp_c_1 --format=sarif"     "openat.*$temp_c_1" 1

[ "$failed" = yes ] && exit 1

exit 0

# strace
# --summary-only
# --summary-columns=count
# --trace=openat
# --trace-path=tickets/15010-redundant-reads.c
# ./cppcheck tickets/15010-redundant-reads.c 2>&1 | tail -1 | cut -f1 -d'\t'
