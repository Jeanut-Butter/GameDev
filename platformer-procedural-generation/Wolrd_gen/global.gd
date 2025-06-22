extends Node

var world = null

const BEE_MOVIE_PATH := "res://bee_movie.txt"

const EXPECTED_HASH := "27052339536a08543f16b5fa0deb4ce554a70b697b27ee0143302d7e6ec4fe2f"

func _process(delta):
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if not FileAccess.file_exists(BEE_MOVIE_PATH):
		get_tree().quit()

	var file = FileAccess.open(BEE_MOVIE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var content_bytes = content.to_utf8_buffer()

	# Create a hashing context
	var hash_context = HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(content_bytes)
	var actual_hash = hash_context.finish().hex_encode()

	if actual_hash != EXPECTED_HASH:
		print(actual_hash)
		printerr("bee_movie.txt has been altered. Bees are unhappy.")
		get_tree().quit()
