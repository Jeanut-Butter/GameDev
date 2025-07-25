extends Area2D

@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0

var direction: int = 1
var start_position: Vector2

func _ready():
	start_position = global_position
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("default")

func _process(delta):
	global_position.x += move_speed * direction * delta

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1
		# Don't teleport! Just reverse direction.

	$AnimatedSprite2D.flip_h = direction < 0

	if !$AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("default")
