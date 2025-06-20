# Bullet.gd
extends RigidBody2D

var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Apply velocity when bullet spawns
	linear_velocity = velocity

func _process(delta):
	# If off-screen, remove bullet
	if not get_viewport_rect().has_point(global_position):
		queue_free()
