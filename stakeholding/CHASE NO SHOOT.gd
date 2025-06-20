extends CharacterBody2D

@export var speed := 100
@export var gravity := 800

var player: CharacterBody2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
func _physics_process(delta):
	velocity.x = 0
	velocity.y += gravity * delta

	if player:
		var offset = player.global_position - global_position
		offset.y = 0

		if offset.length() > 1:
			var direction = offset.normalized()
			velocity.x = direction.x * speed
		else:
			velocity.x = 0

	move_and_slide()
