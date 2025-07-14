extends Area2D # stupid i dont want to use area2d its so much more complicated than characterbody2d why

@export var move_speed: float = 100.0
@export var gravity_force: float = 800.0  # was gravity
@export var patrol_distance: float = 200.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0

var direction: int = 1 
var start_position: Vector2
var velocity: Vector2 = Vector2.ZERO  # should help from character to area2d

func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("default")  
	call_deferred("shoot_repeatedly")  

func _physics_process(delta):
	velocity.y += gravity_force * delta  
	velocity.x = move_speed * direction

	global_position += velocity * delta  # area2d doesn't have move_and_slide()

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
	print("Attempting to shoot")  # debugging to see if its trying to shoot
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
