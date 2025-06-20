extends Area2D

@export var speed = 1800

func shoot(direction: float):
	rotation = direction

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free()
