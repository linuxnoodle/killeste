extends Label

var milliseconds = 0;
var seconds = 0;
var minutes = 0;
var hours = 0;
var time_text = "";
var timer_on = true;

func _process(_delta):
	if (milliseconds > 99):
		seconds += 1;
		milliseconds = 0;
	if (seconds > 59):
		minutes += 1;
		seconds = 0;
	if (minutes > 59):
		hours += 1;
		minutes = 0;
	
	if (hours < 10):
		time_text += "0" + str(hours) + ":";
	else:
		time_text += str(hours) + ":";
	
	if (minutes < 10):
		time_text += "0" + str(minutes) + ":";
	else:
		time_text += str(minutes) + ":";
	
	if (seconds < 10):
		time_text += "0" + str(seconds) + ".";
	else:
		time_text += str(seconds) + ".";
	
	if (milliseconds < 10):
		time_text += "0" + str(milliseconds) ;
	else:
		time_text += str(milliseconds);
	
	text = time_text;
	time_text = "";

func _on_Timer_timeout():
	if (timer_on):
		milliseconds += 1;
	else:
		get_parent().get_parent().self_modulate = Color(1, 1, 1, 1);
		get_parent().get_parent().get_node("Label").modulate = Color(1, 1, 1, 1);
		get_tree().paused = true;
		self_modulate = Color(1, 1, 0, 1)
