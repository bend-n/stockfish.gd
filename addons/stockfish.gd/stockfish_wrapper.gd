class_name Stockfish
extends Reference

var game: Chess setget set_game
var sent_isready := false
var engine_ready := false
var call_queue := PoolStringArray()
var searching_bestmove := false

signal engine_ready
signal line_recieved
signal load_failed
signal bestmove
signal info

func send_line(cmd: String) -> void:
    if not engine_ready:
        call_queue.append(cmd)
        return
    dbg_prints("%s --> stockfish" % cmd)
    _send_line(cmd)

# @override
func _send_line(cmd: String) -> void:
    pass

func _init() -> void:
    connect("line_recieved", self, "_line_recieved")
    connect("engine_ready", self, "_engine_ready")


func dbg_prints(a1 = "", a2 = "") -> void:
    if OS.is_debug_build():
        prints(a1, a2)

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
        for history in game.__history:
            command.append(Chess.move_to_uci(history.move))

    send_line(command.join(" "))

func _line_recieved(line: String) -> void:
    if line.begins_with("info "):
        emit_signal("info", parse_info(line.split(" ", true, 1)[1]))
    elif searching_bestmove and line.begins_with("bestmove "):
        searching_bestmove = false
        parse_bestmove(line.split(" ", true, 1)[1])
    elif (
        (sent_isready)
        && (line == "readyok" || (OS.has_feature("JavaScript") && line.begins_with("Stockfish [commit: ")))
    ):
        sent_isready = false
        print("ENGINE READY")
        emit_signal("engine_ready")
    else:
        push_error("unexpected output: %s" % line)

func parse_bestmove(args: String) -> void:
    var tokens = args.split(" ")
    if tokens and not tokens[0] in ["(none)", "NULL"]:
        if game.move(tokens[0]):
            var bm = game.undo()
            emit_signal("bestmove", bm)
            return
    emit_signal("bestmove", null)


# given a string like
# depth 18 seldepth 21 multipv 1 score cp 74 nodes 351592 nps 267167 hashfull 147 tbhits 0 time 1316 pv e2e4 c7c5 g1f3 d7d6 d2d4 c5d4 f3d4 g8f6 b1c3 e7e5 d4b3 c8e6 c1g5 f8e7 f1b5 b8c6 g5f6 e7f6
# it will produce a dictionary:
# ```json
# {
#   "depth": 18,
#   "seldepth": 21,
#   "multipv": 1,
#   "score": { "cp": 74 },
#   "nodes": 351592,
#   "nps": 267167,
#   "hashfull": 147,
#   "tbhits": 0,
#   "time":1.316,
#   "pv": ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "e7e5", "d4b3", "c8e6", "c1g5", "f8e7", "f1b5", "b8c6", "g5f6", "e7f6"]
# }
# ```
func parse_info(args: String) -> Dictionary:
    var tokens := Array(args.split(" "))
    var info := {}

    while !tokens.empty():
        var parameter: String = tokens.pop_front()

        if parameter == "string":
            info["string"] = " ".join(tokens)
            break
        elif parameter in ["depth", "seldepth", "nodes", "multipv", "currmovenumber", "hashfull", "nps", "tbhits"]:
            info[parameter] = int(tokens.pop_front())  # type: ignore
        elif parameter == "time":
            info["time"] = int(tokens.pop_front()) / 1000.0
        elif parameter == "score":
            # cp 74 ->
            # kind: cp
            # value: 74
            var kind: String = tokens.pop_front()
            var value := int(tokens.pop_front())
            if kind == "cp":
                info["score"] = {cp = value}
            elif kind == "mate":
                info["score"] = {mate = value}
        elif parameter == "currmove":
            info["currmove"] = game.__move_to_san(game.__move_from_uci(tokens.pop_front()))
        elif parameter == "pv":
            var pv: PoolStringArray = tokens.slice(0, len(tokens))
            info["pv"] = pv
    return info

func go(depth: int = 15) -> void:
    if searching_bestmove:
        push_error("already searching. did you mean `stop()`?")
        return
    searching_bestmove = true
    var command := PoolStringArray(["go"])
    command.append("depth")
    command.append(str(depth))
    send_line(command.join(" "))

func stop() -> void:
    send_line("stop")


func kill() -> void:
    send_line("quit")
    engine_ready = false # stop any calls from being sent
    # can not free self. will crash