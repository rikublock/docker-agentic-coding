#!/bin/bash

docker run --rm -it \
  -v ~/.claude:/home/ubuntu/.claude \
  -v $(pwd):/workspace/$(basename $(pwd)) \
  -w /workspace/$(basename $(pwd)) \
  --shm-size=2gb \
  ghcr.io/rikublock/claude:latest
