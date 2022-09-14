extends Stockfish

const loader_code := "const dl=(url,onFinishDownload)=>{fetch(url).then(response=>response.arrayBuffer()).then(data=>onFinishDownload(data))};window.stockfishCommand=function(command){window.stockfish.postMessage(command)};const loadStockfish=async params=>{return await Stockfish(params)};const onFinishDownload=data=>{if(!data){window.stockfish_failed_load();return}loadStockfish({wasmBinary:data}).then(_stockfish=>{window.stockfish=_stockfish;window.stockfish.addMessageListener(line=>window.stockfish_data_recieved(line))}).catch(e=>{window.stockfish_failed_load();throw e})};if(!window.stockfish)dl('./lib/stockfish.wasm',onFinishDownload);"

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

func kill()->void:
    .kill()
    JavaScript.eval("window.stockfish = undefined")