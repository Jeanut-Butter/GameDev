extends Node2D

# line 36 Needs potenitaol adjustment 
# line 105 may need major overhall to include momentum not just velocity 

var player
var is_grappling = false
var grapple_point = Vector2.ZERO

var max_rope_length := 125.0
var min_rope_length := 1.0

var momentum_timer := 0.0
var momentum_duration := 0.2
var post_grapple_velocity := Vector2.ZERO

var grapple_duration := 0.2
var grapple_time := 0.0
var grapple_cooldown := 1.0
var grapple_cooldown_timer := 0.0

@onready var rope := Line2D.new()

func _init(p):
	player = p

func _ready():
	add_child(rope)
	rope.width = 8	
	rope.default_color = Color(0.8, 0.4, 0.4)   # vissuals of grapples rope  

func update(delta):
	if grapple_cooldown_timer > 0.0:
		grapple_cooldown_timer -= delta

	if Input.is_action_pressed("grapple") and grapple_cooldown_timer >= 0.0:  # checks id coolodwn timer is 
		if not is_grappling:
			shoot_grapple()

	else:
		if is_grappling:
			post_grapple_velocity = player.velocity
			momentum_timer = momentum_duration
		is_grappling = false

	if is_grappling:
		grapple_time += delta 
		simulate_grapple(delta)

		if grapple_time >= grapple_duration:
			is_grappling = false
			post_grapple_velocity = player.velocity
			momentum_timer = momentum_duration
			grapple_cooldown_timer = grapple_cooldown  
	elif momentum_timer > 0.0:
		apply_post_grapple_momentum(delta)
	else:
		if is_grappling:
			post_grapple_velocity = player.velocity
			momentum_timer = momentum_duration
			is_grappling = false
			grapple_time = 0.0
			grapple_cooldown_timer = grapple_cooldown


	update_rope()


func shoot_grapple():
	var ray = player.get_node_or_null("Grapple")
	if not ray:
		return

	ray.target_position = player.get_global_mouse_position() - player.global_position
	ray.force_raycast_update()

	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("Grapplable"):
			grapple_point = ray.get_collision_point()
			is_grappling = true
			grapple_time = 0.0



func simulate_grapple(delta):
	var to_grapple = grapple_point - player.global_position
	var distance = to_grapple.length()
	var direction = to_grapple.normalized()

	player.velocity.y += player.gravity * delta

	var grapple_pull_speed =2000.0
	player.velocity = direction * grapple_pull_speed

	var input_x = Input.get_axis("walk_left", "walk_right")
	var input_y = Input.get_axis("move_up", "move_down")  # optional
	var input_force = Vector2(input_x, input_y).normalized() * 300.0
	player.velocity += input_force * delta

	if distance < 50.0:
		is_grappling = false
		post_grapple_velocity = player.velocity
		momentum_timer = momentum_duration


func apply_post_grapple_momentum(delta):
	momentum_timer -= delta
	var t = clamp(momentum_timer / momentum_duration, 0.1, 2.0)

	player.velocity = post_grapple_velocity.lerp(Vector2(
		Input.get_axis("walk_left", "walk_right") * player.speed,
		player.velocity.x
	), 0.5 - t)

func update_rope():
	if is_grappling:
		rope.clear_points()
		rope.add_point(Vector2.ZERO)
		rope.add_point(grapple_point - player.global_position)
	else:
		rope.clear_points()
