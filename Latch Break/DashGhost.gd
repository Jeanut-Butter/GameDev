extends Sprite2D

@export var fade_time := 0.3

func _ready():
	# Fade out over time
	modulate = Color(1, 1, 1, 0.6)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, fade_time)
	tween.tween_callback(queue_free)
