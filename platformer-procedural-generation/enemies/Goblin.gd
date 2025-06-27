extends CharacterBody2D

@export var move_speed: float = 100.0
@export var gravity: float = 800.0
@export var patrol_distance: float = 50.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var max_health: int = 30

var direction: int = 1
var start_position: Vector2
var current_health: int
var is_dead: bool = false
var can_shoot: bool = true

func _ready():
	start_position = global_position
	current_health = max_health
	$AnimatedSprite2D.play("move")
	call_deferred("shoot_repeatedly")

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		return

	velocity.y += gravity * delta
	velocity.x = move_speed * direction
	move_and_slide()

	# Animation and flipping
	$AnimatedSprite2D.play("move")
	$AnimatedSprite2D.flip_h = direction < 0

	var distance_from_start = global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1

func shoot_repeatedly():
	while not is_dead:
		if can_shoot:
			#shoot()
			print("shootery")
		await get_tree().create_timer(shoot_interval).timeout

func shoot():
	if bullet_scene == null or is_dead:
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	$AnimatedSprite2D.play("attack")
	can_shoot = false
	await get_tree().create_timer(0.5).timeout  # Small delay for the attack animation
	can_shoot = true

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	var target_position = players[0].global_position
	var shoot_dir = (target_position - global_position).normalized()
	bullet.shoot(shoot_dir)
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int):
	if is_dead:
		return
	print("owww")
	current_health -= amount
	print("Boss HP:", current_health)
	if current_health <= 0:
		die()
	else:
		$AnimatedSprite2D.play("hurt")


func die():
	is_dead = true
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()
