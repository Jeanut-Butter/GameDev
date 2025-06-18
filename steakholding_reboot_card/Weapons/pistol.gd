extends Node2D
 # simple shooty boi 

@export var bullet_scene: PackedScene
@export var fire_rate = 0.2
var can_shoot = true

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)  # points towards mouse cursor 
	$RotationOffset/Sprite2D.flip_v = global_position.x > get_global_mouse_position().x


func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.rotation = global_rotation
	get_tree().current_scene.add_child(bullet)
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
	

	
