extends CharacterBody2D

@export var speed := 1200
@export var jump_speed := -1600
@export var gravity := 7000
@export var max_jumps = 2
var jump_count := 0

@onready var coyote_timer := $coyoteTimer
@onready var grapple := preload("res://Player/Grapple.gd").new(self)

func _ready():
	add_child(grapple)

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = Input.get_axis("walk_left", "walk_right") * speed
	
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_speed
		jump_count += 1

	grapple.update(delta)  # Call grapple logic

	move_and_slide()
