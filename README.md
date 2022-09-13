# stockfish

[![version](https://img.shields.io/badge/3.x-blue?logo=godot-engine&logoColor=white&label=godot&style=for-the-badge)](https://godotengine.org "Made with godot")
[![package](https://img.shields.io/npm/v/@bendn/stockfish.gd?label=version&style=for-the-badge)](https://www.npmjs.com/package/@bendn/stockfish.gd)
<a href='https://ko-fi.com/bendn' title='Buy me a coffee' target='_blank'><img height='28' src='https://storage.ko-fi.com/cdn/brandasset/kofi_button_red.png' alt='Buy me a coffee'> </a>

## Usage

```gdscript
extends Node

var fish: StockfishLoader.Stockfish


func _ready() -> void:
  var loader := StockfishLoader.new()
  fish = loader.load_stockfish()
  fish.game = Chess.new()
  print("GO FISH")
  fish.go()
```
