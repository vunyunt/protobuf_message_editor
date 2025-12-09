rm -rf ./generated
mkdir ./generated

protoc \
  -I="lib/protos" \
  --dart_out="lib/generated" \
  lib/protos/*.proto
