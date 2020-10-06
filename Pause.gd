extends ColorRect

var pause_state;
var main_menu = preload("res://MainMenu.tscn");

var is_hosting = false;
var is_connected = false;
onready var Networking = get_node("/root/Network");

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		invert_pause();

func invert_pause():
	pause_state = not get_tree().paused;
	get_tree().paused = pause_state;
	self.visible = pause_state;

func _on_Button_pressed():
	invert_pause();

func _on_ExitButton_pressed():
	get_tree().quit();
