extends Control

@export var max_hearts := 5
var current_hearts := max_hearts

@onready var heart_container = $HeartContainer
@onready var heart_scene = preload("res://Heart.tscn")

func setup(player_ref):
	max_hearts = player_ref.max_health
	current_hearts = player_ref.current_health
	
	player_ref.health_changed.connect(update_hearts)
	
	draw_hearts()

func draw_hearts():
	for child in heart_container.get_children():
		child.queue_free()
	for i in max_hearts:
		var heart = heart_scene.instantiate()
		heart_container.add_child(heart)

func update_hearts(new_health):
	current_hearts = new_health
	
	for i in heart_container.get_child_count():
		var heart = heart_container.get_child(i)
		heart.modulate = Color(1, 1, 1, 1) if i < current_hearts else Color(1, 1, 1, 0.2)
