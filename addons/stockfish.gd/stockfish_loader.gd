extends Reference
class_name StockfishLoader


func load_stockfish() -> Stockfish:
	if not is_supported():
		push_error("Platform not supported")
		return null
	if OS.has_feature("JavaScript"):
		var f = File.new()
		f.open("res://addons/stockfish.gd/load.js")
		JavaScript.eval(f.get_as_text())
		f.close()
		return JSStockfish.new()
	return null


func is_supported() -> bool:
	if OS.has_feature("JavaScript"):
		var has_wasm_buffer_atomics := "function s() {if(typeof WebAssembly!=='object')return false;const source=Uint8Array.from([0,97,115,109,1,0,0,0,1,5,1,96,0,1,123,3,2,1,0,7,8,1,4,116,101,115,116,0,0,10,15,1,13,0,65,0,253,17,65,0,253,17,253,186,1,11]);if(typeof WebAssembly.validate!=='function'||!WebAssembly.validate(source))return false;if(typeof Atomics!=='object')return false;if(typeof SharedArrayBuffer!=='function')return false;return true}; s()"
		return JavaScript.eval(has_wasm_buffer_atomics)
	return false


class Stockfish:
	extends Reference

	var game: Chess setget set_game
	var sent_isready := false
	var engine_ready := false
	var call_queue := PoolStringArray()

	signal engine_ready
	signal line_recieved
	signal load_failed
	signal bestmove

	func send_line(cmd: String) -> void:
		if not engine_ready:
			call_queue.append(cmd)
			return
		print("%s --> stockfish" % cmd)
		_send_line(cmd)

	# @override
	func _send_line(cmd: String) -> void:
		pass

	func _init() -> void:
		connect("line_recieved", self, "_line_recieved")
		connect("engine_ready", self, "_engine_ready")

	func _engine_ready() -> void:
		engine_ready = true
		for call in call_queue:
			send_line(call)
		call_queue.resize(0)

	func set_game(new_game: Chess) -> void:
		game = new_game
		send_line("ucinewgame")
		_position()

	func _position():
		var command := PoolStringArray(["position", "startpos"])

		if game.__history:
			command.append("moves")
			for move in game.__history:
				command.append(Chess.move_to_uci(move))

		send_line(command.join(" "))

	func _line_recieved(line: String) -> void:
		if line.begins_with("info "):
			prints("(stockfish)", line)
		elif line.begins_with("bestmove "):
			parse_bestmove(line.split(" ", true, 1)[1])
		elif (sent_isready) && (line == "readyok" || line.begins_with("Stockfish [commit: ")):
			sent_isready = false
			emit_signal("engine_ready")
		else:
			push_error("unexpected output: %s" % line)

	func parse_bestmove(args: String) -> void:
		var tokens = args.split(" ")
		if tokens and not tokens[0] in ["(none)", "NULL"]:
			if game.move(tokens[0]):
				var bm = game.undo()
				emit_signal("bestmove", bm)
		emit_signal("bestmove", null)

	func go(depth: int = 15):
		var command := PoolStringArray(["go"])
		command.append("depth")
		command.append(str(depth))
		send_line(command.join(" "))

	func stop():
		send_line("stop")


class JSStockfish:
	extends Stockfish

	var data_recieved_callback := JavaScript.create_callback(self, "data_recieved")
	var load_failed_callback := JavaScript.create_callback(self, "load_failed")

	func _init() -> void:
		sent_isready = true
		JavaScript.get_interface("window").stockfish_data_recieved = data_recieved_callback
		JavaScript.get_interface("window").stockfish_failed_load = load_failed_callback

	func _send_line(cmd: String) -> void:
		JavaScript.eval("window.stockfishCommand('%s')" % cmd)

	# js callback arguments are in arrays. i guess its so that you can call functions with less args then they want?
	func data_recieved(data: Array) -> void:
		emit_signal("line_recieved", data[0])

	# if _data is omitted, it will not work
	func load_failed(_data: Array) -> void:
		emit_signal("load_failed")
		printerr("load failed")
