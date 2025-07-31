extends CharacterBody2D

# General
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 18
var default_speed = speed
@export var jump_speed := -250
var is_jumping := false

@export var gravity := 900
@export var max_jumps = 2
var is_invincible := false
@export var invincibility_time := 0.5
@onready var melee_hitbox = $MeleeHitbox

# Unlockables
@export var Pistol := false
@export var knife := false
@export var weapon := false
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


#Health system
var max_health := 5
var current_health := max_health
signal health_changed(new_health)
signal maxHealth(maxHealth)
var dead := false


func _ready():
	var player = self
	$InventoryGUI/HeartBar.setup(player)
	current_health = max_health
	emit_signal("maxHealth", max_health)
	gravity_enabled = true
	global_position.x = self.position.x
	print("player is at: ", self.position)
	add_child(grapple)
	melee_hitbox.monitoring = false  # Ensure it's off at start
	
	# Get the GUI node
	var inv = $InventoryGUI

	# Get slot 0 from the GUI
	var slot_0 = inv.get_node("%Inv").get_child(0)

	# Connect relevant signals
	slot_0.connect("gun", Callable(self, "equip_gun"))
	slot_0.connect("knife", Callable(self, "equip_knife"))
	slot_0.connect("no_weapon", Callable(self, "unequip_weapon"))
	
func _physics_process(delta):
	var local_mouse_pos = get_global_mouse_position()
	# Dash

	if gravity_enabled:
		velocity.y += gravity * delta
		if dead:
			move_and_slide()
			return
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10

	if is_on_floor():
		jump_count = 0
	if is_sliding and not is_on_floor():
		is_sliding = false
		speed = default_speed

	
			
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	
	
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		
		ghost_timer -= delta
		if ghost_timer <= 0:
			ghost_timer = 0.5
			
		if dash_timer <= 0:
			is_dashing = false
			is_dash_invincible = false
	else:
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10
			
	# Slide
	if Input.is_action_just_pressed("slide") \
		and can_slide \
		and !is_dashing \
		and !is_attacking \
		and abs(velocity.x) > 0.1:

		can_slide = false
		start_slide()

		can_slide = false  # Lock it BEFORE calling
		start_slide()
	
	
	# Animation
	if !is_attacking:
		var anim_to_play = "Idle"

		if is_sliding:
			anim_to_play = "Slide"
		elif is_attacking:
			pass  # attack animations are already handled
		elif not is_on_floor():
			if velocity.y < 0:
				anim_to_play = "Jumping"
			else:
				anim_to_play = "fall"
		elif abs(velocity.x) > 0.1:
			anim_to_play = "run"

		if sprite.animation != anim_to_play:
			sprite.play(anim_to_play)

	# Reset jump anim when player starts falling
	if is_jumping and velocity.y > 0:
		is_jumping = false

		
	sprite.flip_h = velocity.x < 0

	grapple.update(delta)
	
	move_and_slide()
	
	if Input.is_action_pressed("attack"):
		if not is_attacking and knife:
				start_attack()

	if Input.is_action_just_pressed("jump"):
		if jump_count < max_jumps:
			velocity.y = jump_speed
			is_jumping = true
			jump_count += 1
			sprite.play("Jumping")  # optional; animation also handled in _physics_process
	if Input.is_action_just_pressed("Shoot"):
		if Pistol and gun.has_method("shoot"):
			gun.shoot()
	if Input.is_action_just_pressed("dash"):
		if !is_dashing and dash_cooldown_timer <= 0 and !is_sliding:
			start_dash()
	if Input.is_action_just_pressed("takeDamage"):
		take_damage(1)
	if Input.is_action_just_pressed("Heal"):
		take_damage(-1)


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
	print(current_health)
	current_health -= amount
	is_invincible = true
	if current_health >= max_health:
		current_health = max_health
	if current_health <= 0:
		die()
	else:
		await get_tree().create_timer(invincibility_time).timeout
		is_invincible = false
	emit_signal("health_changed", current_health)
	print(current_health)

func die():
	dead = true
	is_attacking = false
	is_sliding = false
	is_dashing = false
	can_slide = false
	sprite.play("death")
	velocity.x = velocity.x/2
	await sprite.frame == 5
	velocity.x = 0


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



func equip_gun():
	Pistol = true
	knife = false
	gun.visible = true
	melee_hitbox.monitoring = false
	print("Equipped gun")

func equip_knife():
	Pistol = false
	knife = true
	gun.visible = false
	melee_hitbox.monitoring = true
	print("Equipped knife")

func unequip_weapon():
	Pistol = false
	knife = false
	gun.visible = false
	melee_hitbox.monitoring = false
	print("No weapon equipped")
