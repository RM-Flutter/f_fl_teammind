#!/usr/bin/env bash
# Fails when a hand-written shadow or a raw elevation shows up outside the design tokens (rule 13).
cd "$(dirname "$0")/.." || exit 1
bad=0
hits=$(grep -rnE "BoxShadow\(" lib | grep -v "lib/core/constants/app_design.dart" | grep -vE "^[^:]+:[0-9]+:\s*//")
if [ -n "$hits" ]; then echo "BoxShadow outside app_design.dart:"; echo "$hits"; bad=1; fi
hits=$(grep -rnE "elevation: *[1-9]" lib | grep -v "AppElevation" )
if [ -n "$hits" ]; then echo "Raw elevation (use AppElevation.*):"; echo "$hits"; bad=1; fi
[ $bad -eq 0 ] && echo "design tokens: ok"
exit $bad
