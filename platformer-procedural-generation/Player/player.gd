extends CharacterBody2D

# General
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 18
var default_speed = speed
@export var jump_speed := -250
@export var gravity := 900
@export var max_jumps = 2
@export var max_health := 5
var current_health := max_health
var is_invincible := false
@export var invincibility_time := 0.5
@onready var melee_hitbox = $MeleeHitbox

# Unlockables
@export var Pistol := false
@export var knife := false
@export var dash := false
@export var grapple_abblity := false
@export var quick_draw := false

# Dash
@export var dash_speed := 800
@export var dash_duration := 0.120
@export var dash_cooldown := 0.3
var dash_timer := 0.0
@export var dash_cooldown_timer := 0.3
var is_dashing := false
var dash_direction := Vector2.ZERO
var is_dash_invincible := false

var ghost_timer := 0.0
@onready var ghost_scene := preload("res://Player/DashGhost.tscn")

# Slide
var is_sliding := false
var can_slide := true  # replaces is_slide_on_cooldown
@export var slide_speed := speed + (speed/6)
@export var slide_duration := 0.5
@export var slide_cooldown := 0.8

# Jump
var jump_count := 0
var gravity_enabled: bool = false

# Attachments
@onready var coyote_timer := $AnimatedSprite2D/coyoteTimer
@onready var grapple := preload("res://Player/Grapple.gd").new(self)
@onready var gun = $AnimatedSprite2D/Gun	

# Melee Combat
var is_attacking := false
var attack_step := 1
@export var attack_damage := 10

var bulletItem = preload("res://Player/inventory/Items/Bullet.tres")
var knifeItem = preload("res://Player/inventory/Items/Knife.tres")
var pistolItem = preload("res://Player/inventory/Items/Pistol.tres")

func _ready():
	gravity_enabled = true
	global_position.x = self.position.x
	print("player is at: ", self.position)
	add_child(grapple)
	melee_hitbox.monitoring = false  # Ensure it's off at start
	$InventoryUI.visible = false
	
	$InventoryUI.populate_inventory([pistolItem, knifeItem, bulletItem])
	$InventoryUI.visible = false

func _physics_process(delta):
	var local_mouse_pos = get_global_mouse_position()

	# Dash

	if gravity_enabled:
		velocity.y += gravity * delta
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10

	if is_on_floor():
		jump_count = 0

	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_speed
		jump_count += 1

	if Input.is_action_just_pressed("Shoot") and gun.has_method("shoot"):
		#gun.shoot()
		print("wouls shoot if i could")
			
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and !is_dashing and dash_cooldown_timer <= 0:
		start_dash()
	
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		
		ghost_timer -= delta
		if ghost_timer <= 0:
			spawn_dash_ghost()
			ghost_timer = 0.5
			
		if dash_timer <= 0:
			is_dashing = false
			is_dash_invincible = false
	else:
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10
			
	# Slide
	
	if abs(velocity.x) > 0.1 \
		and Input.is_action_just_pressed("slide") \
		and can_slide:

		can_slide = false  # Lock it BEFORE calling
		start_slide()
	
	# Animation
	var anim_to_play = "Idle"
	if abs(velocity.x) > 0.1:
		anim_to_play = "run"
	if abs(velocity.y) < 0.0:
		anim_to_play = "fall"
	if is_sliding:
		anim_to_play = "Slide"
		
	
	if sprite.animation != anim_to_play and not is_attacking:
		sprite.play(anim_to_play)
		
	sprite.flip_h = velocity.x < 0

	grapple.update(delta)

	move_and_slide()
	
	if Input.is_action_just_pressed("OpenInventory"):
		$InventoryUI.visible = !$InventoryUI.visible

func _input(event):
	if event.is_action_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	is_attacking = true
	attack_step += 1
	if attack_step == 1:
		sprite.play("attack_1")
	elif attack_step == 3:
		sprite.play("attack_2")
	elif attack_step == 2:
		sprite.play("attack_chain_1") 
	if attack_step == 3:
		attack_step = 0
	#hixbo
	melee_hitbox.monitoring = true
	await sprite.animation_finished
	melee_hitbox.monitoring = false

	await get_tree().create_timer(0.2).timeout
	is_attacking = false
	#print(attack_step)

func take_damage(amount: int):
	if is_invincible or is_dash_invincible:
		return
	current_health -= amount
	is_invincible = true
	sprite.play("fall")
	if current_health <= 0:
		die()
	else:
		await get_tree().create_timer(invincibility_time).timeout
		is_invincible = false

func die():
	sprite.play("death")
	set_physics_process(false)
	await sprite.animation_finished
	queue_free()

func generation_complete(value):
	gravity_enabled = true

func _on_MeleeHitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)

func start_slide():
	is_sliding = true
	speed = slide_speed
	sprite.play("Slide")

	await get_tree().create_timer(slide_duration).timeout
	is_sliding = false
	speed = default_speed

	await get_tree().create_timer(slide_cooldown).timeout
	can_slide = true  # Unlock after cooldown

func start_dash():
	is_dashing = true
	is_dash_invincible = true
	dash_direction = Vector2(sign(velocity.x), 0)
	if dash_direction == Vector2.ZERO:
		dash_direction.x = -1 if sprite.flip_h else 1
	
	dash_cooldown_timer = dash_cooldown
	dash_timer = dash_duration
	
	ghost_timer = 0
	
func spawn_dash_ghost():
	var ghost = ghost_scene.instantiate()
	#ghost.texture = sprite.sprite_frames.get_frame(sprite.animation, sprite.frame)
	ghost.global_position = global_position
	ghost.scale = sprite.scale
	ghost.flip_h = sprite.flip_h
	get_tree().current_scene.add_child(ghost)
