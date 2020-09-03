extends Control

func _on_StartButton_pressed():
	get_tree().change_scene("res://TestingScene.tscn");

func _on_OptionsButton_pressed():
	print("penis man")

func _on_QuitButton_pressed():
	get_tree().quit();

