extends Control

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		var pause_state = not get_tree().paused;
		get_tree().paused = pause_state;
		self.visible = pause_state; 
