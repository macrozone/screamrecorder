#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MONGO_URL=mongodb://localhost/scream
export ROOT_URL=http://scream.macrozone.ch
export PORT=8100
forever start $DIR/bundle/main.js
