extends Node

var fish: StockfishLoader.Stockfish


func _ready() -> void:
	var loader := StockfishLoader.new()
	fish = loader.load_stockfish()
	yield(fish, "engine_ready")
	fish.run_command("go depth 5")
