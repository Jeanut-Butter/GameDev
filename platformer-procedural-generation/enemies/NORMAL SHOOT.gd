extends CharacterBody2D

@export var move_speed: float = 100.0
@export var gravity: float = 800.0
@export var patrol_distance: float = 200.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 3.0

var direction: int = 1 
var start_position: Vector2 

func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("default")  
	call_deferred("shoot_repeatedly")  # Delay start until scene is ready

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = move_speed * direction
	move_and_slide()

	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.flip_h = direction < 0

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1

func shoot_repeatedly():
	while true:
		shoot()
		await get_tree().create_timer(shoot_interval).timeout

func shoot():
	print("Attempting to shoot")  # DEBUG
	if bullet_scene == null:
		print("bullet_scene is null!")
		return

	var players = get_tree().get_nodes_in_group("Player")
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
