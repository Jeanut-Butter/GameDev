extends CharacterBody2D

@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0

var direction: int = 1
var start_position: Vector2

func _ready():
	start_position = global_position
	
	start_position = global_position  
	$AnimatedSprite2D.play("default")
	print($AnimatedSprite2D.sprite_frames.get_animation_names())

func _physics_process(delta):
	velocity.y = 0  
	velocity.x = move_speed * direction
	move_and_slide()

	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.flip_h = direction > 0

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1
