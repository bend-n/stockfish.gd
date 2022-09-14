#!/usr/bin/env bash

set -e

function install_libs() {
    if [[ ! -d /tmp/stockfish_libs ]]; then
        mkdir /tmp/stockfish_libs
        wget -nv "https://raw.githubusercontent.com/hi-ogawa/stockfish-nnue-wasm-demo/master/public/serve.json" -O /tmp/serve.json &
        wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.js" -O /tmp/stockfish_libs/stockfish.js &
        wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.worker.js" -O /tmp/stockfish_libs/stockfish.worker.js &
        wget -nv "https://cdn.jsdelivr.net/npm/stockfish-nnue.wasm/stockfish.wasm" -O /tmp/stockfish_libs/stockfish.wasm &
        wait
    fi
    cp /tmp/serve.json serve.json
    cp -r /tmp/stockfish_libs/ lib/
}

[[ -d exports ]] && rm -rf exports
mkdir exports

godot --no-window --export "HTML5" exports/index.html
cd exports
install_libs
touch .gdignore
serve --no-compression
