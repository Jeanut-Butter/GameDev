extends Area2D

@export var speed = 2400

func shoot(direction: float):
	rotation = direction

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_area_entered(area):
	if area.is_in_group("walls"):
		queue_free()
