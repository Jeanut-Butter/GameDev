extends Area2D

@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var max_health := 3

var direction: int = 1 
var start_position: Vector2
var current_health := max_health
var is_hurt := false
var is_dead := false

func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("move")  
	call_deferred("shoot_repeatedly")  

func _physics_process(delta):
	if is_dead or is_hurt:
		return  # pause during hurt or death

	# Move left and right (patrol)
	global_position.x += move_speed * direction * delta

	$AnimatedSprite2D.flip_h = direction < 0

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1

	if $AnimatedSprite2D.animation != "move":
		$AnimatedSprite2D.play("move")

func shoot_repeatedly():
	while not is_dead:
		if not is_hurt:
			shoot()
		await get_tree().create_timer(shoot_interval).timeout

func shoot():
	if bullet_scene == null:
		print("bullet_scene is null!")
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		print("No player found")
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position

	var target_position = players[0].global_position
	var shoot_dir = (target_position - global_position).normalized()

	bullet.shoot(shoot_dir)
	get_tree().current_scene.add_child(bullet)
	print("Bullet spawned")

func take_damage(amount: int):
	if is_dead or is_hurt:
		return

	current_health -= amount
	print("Enemy HP:", current_health)

	is_hurt = true
	$AnimatedSprite2D.play("hurt")
	await $AnimatedSprite2D.animation_finished
	is_hurt = false

	if current_health <= 0:
		die()
	else:
		$AnimatedSprite2D.play("move")

func die():
	is_dead = true
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()

# Don't forget this if you're using area detection for bullets
func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		take_damage(1)
		area.queue_free()
	
	if area.is_in_group("player_melee"):
		take_damage(1)
