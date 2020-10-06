extends Node

var playerConnected = false;
var main_slave = false;
var singleplayer = true;
var music = load("res://loop.wav");
func play_music():
	$Music.stream = music;
	$Music.play();
