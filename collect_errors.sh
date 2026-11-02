#!/bin/bash

# Collect app errors from a phone connected over USB into logs/app_errors.log.
#
# The app prints every error as a block between [TM-ERROR] and [TM-ERROR-END]
# (AppErrorReporter._logToConsole). This script reads the phone's log with adb and
# appends each block, with the time and device, as soon as it happens.
#
# Usage: ./collect_errors.sh [device-id]     (stop with Ctrl+C)
# Works with debug and release builds, as long as the phone is connected with USB debugging.

cd "$(dirname "$0")" || exit 1
mkdir -p logs
OUT="logs/app_errors.log"

DEVICE="$1"
if [ -z "$DEVICE" ]; then
  DEVICE=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')
fi
if [ -z "$DEVICE" ]; then
  echo "No phone found. Connect it with USB debugging on, then check: adb devices"
  exit 1
fi
MODEL=$(adb -s "$DEVICE" shell getprop ro.product.model | tr -d '\r')

echo "Collecting errors from $MODEL ($DEVICE) into $OUT ... (Ctrl+C to stop)"
echo "===== session started $(date '+%Y-%m-%d %H:%M:%S') on $MODEL ($DEVICE) =====" >> "$OUT"

# -T 1: only new lines from now on. Flutter prints to the "flutter" log tag.
adb -s "$DEVICE" logcat -T 1 -v brief flutter:I '*:S' \
  | sed -u -e 's/^[A-Z]\/flutter *( *[0-9]*): //' -e 's/\x1b\[[0-9;]*m//g' \
  | awk -v out="$OUT" '
      /\[TM-ERROR\]/ { inside = 1; lines = 0; block = strftime("%Y-%m-%d %H:%M:%S") "  " $0 "\n"; next }
      # The phone log can drop the end marker when the app prints a lot at once (network logs):
      # close the block after its few known lines so it never swallows other output.
      inside && !/\[TM-ERROR-END\]/ && (++lines > 12 || !/^  /) {
        inside = 0
        printf "%s(end of block was lost)\n\n", block >> out; fflush(out)
        count++
        split(block, first, "\n"); sub(/^[^[]*\[TM-ERROR\] /, "", first[1])
        printf "[%d] %s\n", count, first[1]; fflush()
      }
      inside && /\[TM-ERROR-END\]/ {
        inside = 0
        printf "%s\n", block >> out; fflush(out)
        count++
        split(block, first, "\n"); sub(/^[^[]*\[TM-ERROR\] /, "", first[1])
        printf "[%d] %s\n", count, first[1]; fflush()
        next
      }
      inside { block = block $0 "\n" }
    '
