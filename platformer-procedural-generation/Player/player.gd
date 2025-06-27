extends CharacterBody2D

# genneral values 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed := 18
@export var jump_speed := -250
@export var gravity := 900
@export var max_jumps = 2

# unlockables trough tutorial 

@export var Pistol: = false
@export var knife: = false
@export var dash: = false
@export var grapple_abblity = false
@export var quick_draw: = false

# Dash 

@export var dash_speed := 600
@export var dash_duration := 0.15
@export var dash_cooldown := 0.5

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var is_dashing := false
var dash_direction := Vector2.ZERO


 # instead if checking if player is on ground to jump,
# simply have a jump count that limits how many times the play can jump

var jump_count := 0

var gravity_enabled: bool = false

@onready var coyote_timer := $AnimatedSprite2D/coyoteTimer
@onready var grapple := preload("res://Player/Grapple.gd").new(self)
@onready var gun = $AnimatedSprite2D/Gun	


func _ready():
	#print("Gun node:", $Gun)
	#print("Script attached to Gun:", $Gun.get_script())
	#print("Has shoot():", $Gun.has_method("shoot"))
	# debug lines 
	gravity_enabled = true
	global_position.x = self.position.x
	print("player is at: ", self.position)
	add_child(grapple)
	
func _physics_process(delta):
	var local_mouse_pos = get_global_mouse_position()

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing and dash:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		dash_direction = Vector2(sign(velocity.x), 0)
		if dash_direction == Vector2.ZERO:
			dash_direction.x = -1 if sprite.flip_h else 1 

	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if gravity_enabled:
			velocity.y += gravity * delta
			velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10

		if is_on_floor():
			jump_count = 0

		if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1
			

		if Input.is_action_just_pressed("Shoot") and gun.has_method("shoot"):
			gun.shoot()

	var anim_to_play = "Idle"
	if abs(velocity.x) > 0.1:
		anim_to_play = "run" if Pistol or knife else "run"

	if sprite.animation != anim_to_play:
		sprite.play(anim_to_play)

	sprite.flip_h = velocity.x < 0

	# Grapple
	grapple.update(delta)

	move_and_slide()



func generation_complete(value):
	gravity_enabled = true
