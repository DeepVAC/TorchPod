#!/bin/bash
set -x
if [[ $1 == "standard" ]];then
  CUDA_VER="11.1.1"
  docker build -t gemfield/torchpod:$CUDA_VER-cudatoolkit-ubuntu20.04 -f Dockerfile .
fi

if [[ $1 == "pro" ]];then
  CUDA_VER="11.2.2"
  docker build -t gemfield/torchpod:$CUDA_VER-cudnn8-devel-ubuntu20.04 -f Dockerfile.pro .
fi
