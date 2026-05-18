#!/bin/bash

docker run --rm -it \
  -v ~/.copilot:/home/ubuntu/.copilot \
  -v $(pwd):/workspace/$(basename $(pwd)) \
  -w /workspace/$(basename $(pwd)) \
  --shm-size=2gb \
  ghcr.io/rikublock/copilot:latest
