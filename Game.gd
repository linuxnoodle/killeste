extends Node

onready var Global = get_node("/root/MusicController");

func _ready():
	if (not Global.singleplayer):
		get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
		get_tree().connect('server_disconnected', self, '_on_server_disconnected')
		
		var new_player = preload('res://Player.tscn').instance()
		new_player.name = str(get_tree().get_network_unique_id())
		new_player.set_network_master(get_tree().get_network_unique_id())
		add_child(new_player)
		var info = Network.self_data
		new_player.init(info.position, false)

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/Menu.tscn')
