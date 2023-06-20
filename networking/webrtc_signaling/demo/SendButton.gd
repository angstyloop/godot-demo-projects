extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _log(msg):
	print(msg)
	get_parent().get_node("TextEdit").text += str(msg) + "\n"

@rpc("any_peer", "call_local")
func send_message(message: String):
	_log("%d: %s" % [multiplayer.get_remote_sender_id(), message])

func _on_pressed():
	var peer_id = get_parent().get_node("HBoxContainer2").get_node("OptionButton").get_selected_peer_id()
	if !peer_id:
		return
	var message = get_parent().get_node("LineEdit").text
	rpc_id(peer_id, "send_message", message)
