extends Node

onready var Global = get_node("/root/MusicController");
onready var Player = load("res://Player.tscn").instance();

func _ready():
	if (not Global.singleplayer):
		get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
		get_tree().connect('server_disconnected', self, '_on_server_disconnected')
		
		Player.name = str(get_tree().get_network_unique_id());
		Player.set_network_master(get_tree().get_network_unique_id());
		add_child(Player);
		var info = Network.self_data;
		Player.init(info.position, false);
	else:
		add_child(Player);

func _on_player_disconnected(id):
	get_node(str(get_tree().get_network_unique_id())).queue_free()

func _on_server_disconnected():
	Global.singleplayer = true;
	get_node(str(get_tree().get_network_unique_id())).queue_free();
	get_tree().change_scene('res://TestingScene.tscn');
