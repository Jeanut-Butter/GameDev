extends Control

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://world.tscn")  

func _on_quit_pressed():
	get_tree().quit()


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Tileset/ROOM_CREATOR.tscn")  
