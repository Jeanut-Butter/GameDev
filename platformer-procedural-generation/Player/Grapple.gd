extends Node2D

var player
var is_grappling = false
var grapple_point = Vector2.ZERO

var max_rope_length := 400.0
var min_rope_length := 30.0

var momentum_timer := 0.0
var momentum_duration := 0.2
var post_grapple_velocity := Vector2.ZERO

var grapple_duration := 0.8
var grapple_time := 0.0
var grapple_cooldown := 2.0
var grapple_cooldown_timer := 0.0

@onready var rope := Line2D.new()

func _init(p):
	player = p

func _ready():
	add_child(rope)
	rope.width = 8	
	rope.default_color = Color(0.0, 0.0, 0.0)

func update(delta):
	if grapple_cooldown_timer > 0.0:
		grapple_cooldown_timer -= delta

	if Input.is_action_pressed("grapple") and grapple_cooldown_timer <= 0.0:
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

	update_rope()

func shoot_grapple():
	var from_pos = player.global_position
	var to_pos = player.get_global_mouse_position()

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(from_pos, to_pos)
	query.exclude = [player]
	query.collision_mask = 0xFFFFFFFF  
	query.hit_from_inside = true       


	var result = space_state.intersect_ray(query)

	if result and "position" in result:
		var collider = result.collider
		if collider and (collider.is_in_group("Grapplable") or collider is TileMap):
			grapple_point = result.position
			is_grappling = true
			grapple_time = 0.0



func simulate_grapple(delta):
	var to_grapple = grapple_point - player.global_position
	var distance = to_grapple.length()
	var direction = to_grapple.normalized()

	player.velocity.y += player.gravity * delta

	var grapple_pull_speed = 400.0
	player.velocity = direction * grapple_pull_speed

	var input_x = Input.get_axis("walk_left", "walk_right")
	var input_y = Input.get_axis("move_up", "move_down")
	var input_force = Vector2(input_x, input_y).normalized() * 800.0
	player.velocity += input_force * delta

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
