extends CharacterBody2D

# Chanable varriables for player can be alteredoutside of code temproralily  

@export var speed := 1200
@export var jump_speed := -1600
@export var gravity := 7000
@export var max_jumps = 2
 # instead if checking if player is on ground to jump,
# simply have a jump count that limits how many times the play can jump  in a rpw 
var jump_count := 0

var gravity_enabled: bool = false

@onready var coyote_timer := $coyoteTimer
@onready var grapple := preload("res://Player/Grapple.gd").new(self)
@onready var gun = $Gun


func _ready():
	#print("Gun node:", $Gun)
	#print("Script attached to Gun:", $Gun.get_script())
	#print("Has shoot():", $Gun.has_method("shoot"))
	# debug lines 
	add_child(grapple)
	
func _physics_process(delta):
	var local_mouse_pos = get_global_mouse_position()
	
	if gravity_enabled == true:
		velocity.y += gravity * delta
		velocity.x = Input.get_axis("walk_left", "walk_right") * speed  # makes velocity a thing 
		if Input.is_action_just_pressed("Shoot") and gun.has_method("shoot"):
			gun.shoot()
		if is_on_floor():
			jump_count = 0
		
		if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1
			
		#if (local_mouse_pos.x < 0):
			#scale.x = -1
		#else:
			#scale.x = 1

		grapple.update(delta)  # Call grapple logic

		move_and_slide()

func generation_complete(value):
	gravity_enabled = true
