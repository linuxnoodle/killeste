extends Node

var music = load("res://loop.wav");
func play_music():
	$Music.stream = music;
	$Music.play();
