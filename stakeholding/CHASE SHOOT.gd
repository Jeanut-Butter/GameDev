extends CharacterBody2D

@export var move_speed: float = 100.0
@export var gravity: float = 800.0
@export var patrol_distance: float = 200.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0

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
	if bullet_scene == null:
		print("⚠️ Bullet scene not set!")
		return
	
	var player = get_tree().get_nodes_in_group("player")
	if player.size() == 0:
		print("⚠️ No player found in group!")
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position

	var target_position = player[0].global_position
	var angle = (target_position - global_position).angle()
	bullet.rotation = angle
	
	get_tree().current_scene.add_child(bullet)
	print("💥 Enemy shot!")
