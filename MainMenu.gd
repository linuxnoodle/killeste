extends Control

var is_hosting = false;
var singleplayer = true;
onready var Networking = get_node("/root/Network");
onready var Global = get_node("/root/MusicController");

onready var start_button = $HSplitContainer/ButtonContainer/VBoxContainer/StartButton;
onready var quit_button = $HSplitContainer/ButtonContainer/VBoxContainer/QuitButton;

func _ready():
	MusicController.play_music();

# changes scene to main
func _on_StartButton_pressed():
	if (is_hosting):
		Networking.start_hosting(get_tree().get_network_unique_id());
		if (not Global.singleplayer):
			get_node("WaitingPanel").visible = true;
			while (!Global.playerConnected):
				yield(get_tree().create_timer(1), "timeout");
	elif (not Global.singleplayer):
		var server_ip = get_node("ButtonContainer/VBoxContainer/HSplitContainer2/LineEdit").text;
		var player_name = get_node("ButtonContainer/VBoxContainer/HSplitContainer/LineEdit").text;
		Networking.join_server(player_name, server_ip);
	get_tree().change_scene("res://TestingScene.tscn");

# quits game
func _on_QuitButton_pressed():
	get_tree().quit();

func _on_CheckBox_toggled(button_pressed):
	is_hosting = button_pressed;
	Global.main_slave = not button_pressed;

func _on_CheckBox2_toggled(button_pressed):
	Global.singleplayer = button_pressed;
