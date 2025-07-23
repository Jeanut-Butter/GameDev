extends ProgressBar

@export var player : Node

func setup(player_ref):
	player_ref.health_changed.connect(update_health)
	player_ref.maxHealth.connect(max_health)
	update_health(player_ref.current_health)
	max_health(player_ref.max_health)
	print("Connecting to player: ", player_ref)
	print("Player health: ", player_ref.current_health)

func update_health(new_value):
	value = new_value
	
func max_health(new_value):
	value = new_value
