extends Node2D

@export var speed = 800
var direction = Vector2.ZERO

func shoot(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free()
