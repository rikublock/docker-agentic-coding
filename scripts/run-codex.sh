#!/bin/bash

docker run --rm -it \
  -v ~/.codex:/home/ubuntu/.codex \
  -v $(pwd):/workspace/$(basename $(pwd)) \
  -w /workspace/$(basename $(pwd)) \
  --shm-size=2gb \
  ghcr.io/rikublock/codex:latest
