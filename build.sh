#!/bin/bash

cd "$(dirname "$0")"

set -ex

mkdir -p build
cd build
cmake ..
make
