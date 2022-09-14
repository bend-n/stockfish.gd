extends Reference
class_name StockfishLoader

const JSStockfish = preload("./platform/js_stockfish.gd")


func load_stockfish() -> Stockfish:
	if not is_supported():
		push_error("Platform not supported")
		return null
	if OS.has_feature("JavaScript"):
		JavaScript.eval(JSStockfish.loader_code)
		return JSStockfish.new()
	return null


func is_supported() -> bool:
	if OS.has_feature("JavaScript"):
		var has_wasm_buffer_atomics := "function s() {if(typeof WebAssembly!=='object')return false;const source=Uint8Array.from([0,97,115,109,1,0,0,0,1,5,1,96,0,1,123,3,2,1,0,7,8,1,4,116,101,115,116,0,0,10,15,1,13,0,65,0,253,17,65,0,253,17,253,186,1,11]);if(typeof WebAssembly.validate!=='function'||!WebAssembly.validate(source))return false;if(typeof Atomics!=='object')return false;if(typeof SharedArrayBuffer!=='function')return false;return true}; s()"
		return JavaScript.eval(has_wasm_buffer_atomics)
	return false
