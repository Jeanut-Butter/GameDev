extends CharacterBody2D

# Chanable varriables for player can be alteredoutside of code temproralily  
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed := 18
@export var jump_speed := -250
@export var gravity := 900
@export var max_jumps = 2

@export var Pistol: = false
@export var knife: = false
@export var dash: = false
@export var grapple_abblity = false
@export var quick_draw: = false


 # instead if checking if player is on ground to jump,
# simply have a jump count that limits how many times the play can jump  in a rpw 

@export var inv: Inv

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
	
	if gravity_enabled:
		# Gravity and movement
		velocity.y += gravity * delta
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed * 10

		if Input.is_action_just_pressed("Shoot") and gun.has_method("shoot"):
			gun.shoot()

		if is_on_floor():
			jump_count = 0

		if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1

		var anim_to_play = "Idle"
		if abs(velocity.x) > 0.1:
			if Pistol or knife:
				anim_to_play = "walk_arm_extended"
			else:
				anim_to_play = "Walk_unarmed"

		if sprite.animation != anim_to_play:
			sprite.play(anim_to_play)

		sprite.flip_h = velocity.x < 0
		
		# Grapple logic
		grapple.update(delta)

		# Move
		move_and_slide()


func generation_complete(value):
	gravity_enabled = true
