extends Area2D

@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0
@export var max_health := 2

var direction: int = 1
var start_position: Vector2
var current_health := max_health
var is_dead := false
var is_hurt := false

func _ready():
	start_position = global_position
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("default")

func _process(delta):
	if is_dead or is_hurt:
		return

	global_position.x += move_speed * direction * delta

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1

	$AnimatedSprite2D.flip_h = direction < 0

	if !$AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("default")

func take_damage(amount: int):
	if is_dead or is_hurt:
		return

	current_health -= amount
	is_hurt = true
	$AnimatedSprite2D.play("hurt")
	await $AnimatedSprite2D.animation_finished
	is_hurt = false

	if current_health <= 0:
		die()
	else:
		$AnimatedSprite2D.play("default")

func die():
	is_dead = true
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()
