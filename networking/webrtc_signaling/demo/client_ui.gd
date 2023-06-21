extends Control

@onready var client = $Client
@onready var host = $VBoxContainer/Connect/Host
@onready var room = $VBoxContainer/Connect/RoomSecret
@onready var mesh = $VBoxContainer/Connect/Mesh

var peer_id
var player_info

func _ready():
	client.lobby_joined.connect(self._lobby_joined)
	client.lobby_sealed.connect(self._lobby_sealed)
	client.connected.connect(self._connected)
	client.disconnected.connect(self._disconnected)

	multiplayer.connected_to_server.connect(self._mp_server_connected)
	multiplayer.connection_failed.connect(self._mp_server_disconnect)
	multiplayer.server_disconnected.connect(self._mp_server_disconnect)
	multiplayer.peer_connected.connect(self._mp_peer_connected)
	multiplayer.peer_disconnected.connect(self._mp_peer_disconnected)

	player_info = get_parent().get_parent().get_parent().player_info

@rpc("any_peer", "call_local")
func ping(argument):
	_log("[Multiplayer] Ping from peer %d: arg: %s" % [multiplayer.get_remote_sender_id(), argument])


func _mp_server_connected():
	_log("[Multiplayer] Server connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("[Multiplayer] Peer %d connected" % id)
	var string_id
	var own_id = str(client.rtc_mp.get_unique_id())
	var option_button = $VBoxContainer/HBoxContainer2/OptionButton
	option_button.refresh_peers()
	

func _mp_peer_disconnected(id: int):
	_log("[Multiplayer] Peer %d disconnected" % id)


func _connected(id):
	_log("[Signaling] Server connected with ID: %d" % id)


func _disconnected():
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])

func lookup_by_name(name):
	for peer_id in player_info.keys():
		if player_info[peer_id].name == name:
			return player_info[peer_id]
	return null

func _lobby_joined(lobby):
	_log("[Signaling] Joined lobby %s" % lobby)
	peer_id = client.rtc_mp.get_unique_id()
	$VBoxContainer/Label.text = "Peer ID: %s" % str(peer_id)


func _lobby_sealed():
	_log("[Signaling] Lobby has been sealed")

func _log(msg):
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"


func _on_peers_pressed():
	_log(multiplayer.get_peers())


func _on_ping_pressed():
	ping.rpc(randf())


func _on_seal_pressed():
	client.seal_lobby()


func _on_start_pressed():
	client.start(host.text, room.text, mesh.button_pressed)


func _on_stop_pressed():
	client.stop()

var message_logs = {}

@rpc("any_peer", "call_local")
func send_message(message: String):
	var sender_id = multiplayer.get_remote_sender_id()
	var log_message = "%d: %s" % [sender_id, message]
	_log(log_message)
	if !message_logs.has(sender_id):
		message_logs[sender_id] = ""
	message_logs[sender_id] += log_message + "\n"

func _on_button_pressed():
	var peer_id = $VBoxContainer/HBoxContainer2/OptionButton.get_selected_peer_id()
	if !peer_id:
		return
	var message = get_node("VBoxContainer").get_node("LineEdit").text
	rpc_id(peer_id, "send_message", message)

var selected_peer_id = 1

func _on_option_button_item_selected(index):
	selected_peer_id = int($VBoxContainer/HBoxContainer2/OptionButton.peer_ids[index])
	if !message_logs.has(selected_peer_id):
		message_logs[selected_peer_id] = ""
	$VBoxContainer/TextEdit.text = message_logs[selected_peer_id]

@rpc("any_peer", "call_local")
func refresh_peers():
	var option_button = $VBoxContainer/HBoxContainer2/OptionButton
	option_button.refresh_peers()

@rpc("any_peer", "call_local")
func register_player(info: Dictionary):
	if (peer_id != 1):
		return
		
	var sender_id = multiplayer.get_remote_sender_id()
	info.peer_id = sender_id
	player_info[sender_id] = info
	
	rpc("refresh_peers")

func _on_register_pressed():
	if (peer_id == 1):
		return
	var el = $VBoxContainer/LineEdit2
	var name = el.text
	if name == null or len(name) == 0:
		name = "user_%d" % randi()
	var info = lookup_by_name(name)
	while info != null:
		var old_name = name
		name = "user_%d" % randi()
		_log("Name %s already taken. Generated new name %s. Register again at any time." % [old_name, name])
		info = lookup_by_name(name)
	info = {}
	info.name = name
	info.player_id = randi()
	info.peer_id = peer_id
	rpc_id(1, "register_player", info)
	$VBoxContainer/Label.text += "    Name: %s" % name
