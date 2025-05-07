#!/bin/bash

set -e

echo ">>> Building..."
./build.sh

echo ">>> Starting..."
./run.sh

echo ">>> Connecting..."
sshpass -p "password" ssh -p 1022 -Ppassword jb-gateway@localhost