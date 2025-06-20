extends Node

var world = null

const BEE_MOVIE_PATH := "res://bee_movie.txt"

func _process(delta):
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if not FileAccess.file_exists(BEE_MOVIE_PATH):
		get_tree().quit()
