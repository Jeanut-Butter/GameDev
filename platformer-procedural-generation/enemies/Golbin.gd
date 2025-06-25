extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK, DAMAGED }
var state = State.IDLE

@onready var animation_player = $AnimatedSprite2D
@onready var attack_hitbox = $"Area2D/meele hitbox"
@onready var player = get_node("../Player")  # Adjust path as needed
@onready var timer = $Timer

var speed = 1
var attack_range = 32

func _ready():
	attack_hitbox.monitoring = false

func _process(delta):
	match state:
		State.IDLE:
			if player and global_position.distance_to(player.global_position) < 100:
				state = State.CHASE

		State.CHASE:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()

			animation_player.play("Run")

			if global_position.distance_to(player.global_position) < attack_range:
				state = State.ATTACK

		State.ATTACK:
			velocity = Vector2.ZERO
			animation_player.play("Attack")
			timer.start()  # Start cooldown

		State.DAMAGED:
			animation_player.play("Damaged")

func enable_attack_hitbox():
	attack_hitbox.monitoring = true

func disable_attack_hitbox():
	attack_hitbox.monitoring = false

func _on_AttackHitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(10)

func _on_AttackCooldown_timeout():
	state = State.CHASE

func take_damage():
	state = State.DAMAGED
	# You can add a timer here to return to chase/idle after some time
	await get_tree().create_timer(0.5).timeout
	state = State.CHASE
