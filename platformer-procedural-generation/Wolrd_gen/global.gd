extends Node

var world = null

var file = FileAccess.open("res://download.jfif", FileAccess.READ)
var raw_bytes = file.get_buffer(file.get_length())

const EXPECTED_HASH := "3f45805db77e39d6f4aa834ca4c180cae051ed171516244fc6dce47caa552b91"

func _process(delta):
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	var hash_ctx = HashingContext.new()
	hash_ctx.start(HashingContext.HASH_SHA256)
	hash_ctx.update(raw_bytes)
	var image_hash = hash_ctx.finish().hex_encode()

	if image_hash != EXPECTED_HASH:
		printerr("Chocolate milk is corrupted. Game over.")
		get_tree().quit()
