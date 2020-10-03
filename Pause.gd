extends ColorRect

var pause_state;
var main_menu = preload("res://MainMenu.tscn");

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		invert_pause();

func _on_Button_pressed():
	invert_pause();

func _on_ExitButton_pressed():
	get_tree().quit();

func invert_pause():
	pause_state = not get_tree().paused;
	get_tree().paused = pause_state;
	self.visible = pause_state;
