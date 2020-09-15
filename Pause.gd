extends ColorRect

var pause_state;

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		invert_pause();

func invert_pause():
	pause_state = not get_tree().paused;
	get_tree().paused = pause_state;
	print(pause_state)
	self.visible = pause_state;
