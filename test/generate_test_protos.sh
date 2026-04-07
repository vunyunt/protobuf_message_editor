#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

# Create generated directory if it doesn't exist
mkdir -p test/lib/generated

# Find protoc (assume it's in path)
# Run protoc
protoc \
  -I="test/protos" \
  --dart_out="test/lib/generated" \
  test/protos/*.proto
