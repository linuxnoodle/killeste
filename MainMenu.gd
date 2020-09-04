extends Control

# changes scene to main
func _on_StartButton_pressed():
	get_tree().change_scene("res://TestingScene.tscn");

# placeholder
func _on_OptionsButton_pressed():
	print("penis man")

# quits game
func _on_QuitButton_pressed():
	get_tree().quit();

