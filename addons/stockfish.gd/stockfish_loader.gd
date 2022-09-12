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

	signal engine_ready
	signal data_received
	signal load_failed

	func run_command(cmd: String) -> void:
		pass


class JSStockfish:
	extends Stockfish

	var data_recieved_callback := JavaScript.create_callback(self, "data_recieved")
	var load_failed_callback := JavaScript.create_callback(self, "load_failed")
	var ready_callback := JavaScript.create_callback(self, "ready")

	func _init() -> void:
		JavaScript.get_interface("window").stockfish_data_recieved = data_recieved_callback
		JavaScript.get_interface("window").stockfish_failed_load = load_failed_callback
		JavaScript.get_interface("window").stockfish_ready = ready_callback

	func run_command(cmd: String) -> void:
		JavaScript.eval("window.stockfishCommand('%s')" % cmd)

	# js callback arguments are in arrays. i guess its so that you can call functions with less args then they want?
	func data_recieved(data:Array) -> void:
		emit_signal("data_received", data[0])
		print(data[0])

	# if _data is omitted, it will not work
	func load_failed(_data:Array) -> void:
		emit_signal("load_failed")
		printerr("load failed")
	
	#          ditto
	func ready(_data:Array) -> void:
		emit_signal("engine_ready")

