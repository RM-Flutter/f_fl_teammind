#!/bin/bash

# Fix repos/repo
find lib/features/services -type d -name "repo" | while read d; do
  git mv "$d" "${d}s" || mv "$d" "${d}s"
done

# Fix controller/controllers
find lib/features/services -type d -name "controller" | while read d; do
  git mv "$d" "${d}s" || mv "$d" "${d}s"
done

