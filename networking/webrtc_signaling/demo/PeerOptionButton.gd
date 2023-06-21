extends OptionButton

var peers = {}
var peer_ids = []
var client

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_peers()
	selected = 0
	
func refresh_peers():
	var client_api = get_parent().get_parent().get_parent()
	client = client_api.get_node("Client")
	peers = client.rtc_mp.get_peers()
	peer_ids = peers.keys()
	clear()
	for id in peer_ids:
		if id == 1:
			add_item("server")
		elif client_api.player_info.has(id):
			var s = client_api.player_info[id].name
			add_item(s)

func get_selected_peer_id():
	if selected == -1 or len(peer_ids) == 0:
		return null
	return peer_ids[selected]
	
func get_selected_peer():
	var peer_id = get_selected_peer_id()
	if !peer_id:
		return null
	return peers[peer_id]
