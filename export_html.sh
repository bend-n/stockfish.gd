#!/usr/bin/env bash

set -e

function install_libs() {
    mkdir lib/
    wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.js" -O lib/stockfish.js &
    wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.worker.js" -O lib/stockfish.worker.js &
    wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.wasm" -O lib/stockfish.wasm &
    wget -nv "https://raw.githubusercontent.com/hi-ogawa/stockfish-nnue-wasm-demo/master/public/serve.json" -O serve.json &
    wait
}

[[ -d exports ]] && rm -rf exports
mkdir exports
[[ -f web/load.js ]] && uglifyjs web/load.js | tr "\"" "'" >addons/stockfish.gd/load.js
godot --no-window --export "HTML5" exports/index.html
cd exports
install_libs
touch .gdignore
serve --no-compression
