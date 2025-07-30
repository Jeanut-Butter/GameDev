extends Node2D
 # simple shooty boi 

@export var bullet_scene: PackedScene
@export var fire_rate = 0.2
var can_shoot = true
@export var MagAmmo := 6
@export var MagSize := 6
@export var TotalAmmo := 12
@export var reloading := false

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)  # points towards mouse cursor 
	$RotationOffset/Sprite2D.flip_v = global_position.x > get_global_mouse_position().x


func shoot():
	if MagAmmo > 0:
		MagAmmo -= 1
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = global_rotation
		get_tree().current_scene.add_child(bullet)
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true
		print("shooted")
	elif MagAmmo == 0 and reloading == false:
		reload()
		print("realodings")

func reload():
	reloading = true
	await get_tree().create_timer(1).timeout
	if TotalAmmo >= MagSize:
		TotalAmmo -= MagSize
		MagAmmo += MagSize
	elif TotalAmmo <= MagSize:
		TotalAmmo -= TotalAmmo
		MagAmmo += TotalAmmo
	reloading = false
