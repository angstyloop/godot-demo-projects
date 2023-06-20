extends OptionButton

var peers = {}
var peer_ids = []
var client

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_peers()
	
func refresh_peers():
	client = get_parent().get_parent().get_node("Client")
	peers = client.rtc_mp.get_peers()
	peer_ids = peers.keys()
	print(peer_ids)
	clear()
	for id in peer_ids:
		add_item(id)
	
func get_selected_peer():
	return peers[peer_ids[selected]]
