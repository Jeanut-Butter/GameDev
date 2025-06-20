extends CharacterBody2D  # This script is for a 2D character that can move and interact with physics (like an enemy).

@export var speed := 100  # Movement speed of the enemy (editable in the editor).
@export var gravity := 800  # Gravity force applied to the enemy (also editable).

var player: CharacterBody2D  # This will store a reference to the player once found.

func _ready():
	# Called when the enemy is added to the scene.
	# Search for all nodes in the "player" group.
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]  # Use the first player found in the group.

func _physics_process(delta):
	# This function runs every physics frame (~60 times per second).

	# Reset horizontal velocity to 0 each frame so we can recalculate it.
	velocity.x = 0

	# Apply gravity to the vertical velocity.
	velocity.y += gravity * delta

	if player:
		# Calculate the offset (difference) between player and enemy positions.
		var offset = player.global_position - global_position
		offset.y = 0  # Ignore vertical movement; we only want to move left/right.

		if offset.length() > 1:
			# If the enemy is not too close to the player, normalize the direction
			# so it has a length of 1 (just direction), then multiply by speed.
			var direction = offset.normalized()
			velocity.x = direction.x * speed
		else:
			# If very close to the player, don't move horizontally.
			velocity.x = 0

	# Apply the movement using built-in physics handling.
	move_and_slide()
