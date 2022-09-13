# stockfish

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
