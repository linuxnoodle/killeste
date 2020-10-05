extends Label

var milliseconds = 0;
var seconds = 0;
var minutes = 0;
var hours = 0;
var time_text = "";

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
	milliseconds += 1;
