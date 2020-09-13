extends Control

var pressed = false;
var pressed2 = false;
var pressed3 = false;

onready var start_button = $HSplitContainer/ButtonContainer/VBoxContainer/StartButton;
onready var options_button = $HSplitContainer/ButtonContainer/VBoxContainer/OptionsButton;
onready var quit_button = $HSplitContainer/ButtonContainer/VBoxContainer/QuitButton;

func _ready():
	MusicController.play_music();

# changes scene to main
func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://TestingScene.tscn");

# placeholder
func _on_OptionsButton_pressed():
	print("penis man")

# quits game
func _on_QuitButton_pressed():
	get_tree().quit();
