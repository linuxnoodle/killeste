extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 31400
const MAX_CLIENTS = 2;
onready var Global = get_node("/root/MusicController");

#var upnp;
var peer;

var players = { }
var self_data = { name = '', position = Vector2(0, 0) }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func start_hosting(NAME):
	#upnp = UPNP.new();
	#upnp.discover(2000, 2, "InternetGatewayDevice");
	#upnp.add_port_mapping(DEFAULT_PORT);
	
	self_data.name = NAME;
	players[1] = self_data;
	
	peer = NetworkedMultiplayerENet.new();
	peer.create_server(DEFAULT_PORT, MAX_CLIENTS);
	
	get_tree().set_network_peer(peer);
	print(str(DEFAULT_IP) + ":" + str(DEFAULT_PORT));

func stop_hosting():
	#upnp.delete_port_mapping(DEFAULT_PORT);
	get_tree().network_peer = null

func join_server(NAME, SERVER_IP):
	self_data.name = NAME;
	
	get_tree().connect('connected_to_server', self, '_connected_to_server');
	print("connected")
	var peer = NetworkedMultiplayerENet.new();
	peer.create_client(SERVER_IP, DEFAULT_PORT);
	get_tree().set_network_peer(peer);

func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
	Global.playerConnected = true;
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server() and not Global.singleplayer:
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])

# A function to be used if needed. The purpose is to request all players in the current session.
remote func _request_players(request_from_id):
	if get_tree().is_network_server() and not Global.singleplayer:
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])

remote func _send_player_info(id, info):
	if (not Global.singleplayer):
		players[id] = info
		var new_player = load('res://Player.tscn').instance()
		new_player.name = str(id)
		new_player.set_network_master(id)
		get_tree().get_root().add_child(new_player);
		new_player.init(info.position, true)

func update_position(id, position):
	if (not Global.singleplayer):
		players[id].position = position
