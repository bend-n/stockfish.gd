extends Node

var fish: Stockfish


func _ready() -> void:
	var loader := StockfishLoader.new()
	fish = loader.load_stockfish()
	fish.game = Chess.new()
	while not fish.game.game_over():
		fish.go(5)
		var bestmove = yield(fish, "bestmove")
		prints("bestmove", "is", fish.game.move(bestmove).san)
		fish._position()
	print(fish.game.pgn(), "\n", fish.game.fen())
