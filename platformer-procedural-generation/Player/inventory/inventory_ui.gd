extends Control

@onready var grid: GridContainer = $Panel/GridContainer

func _process(delta):
	if $Panel/Tooltip.visible:
		$Panel/Tooltip.position = get_viewport().get_mouse_position() + Vector2(10, 10)

func populate_inventory(items: Array):
	for i in range(items.size()):
		var slot = preload("res://Player/inventory/InventorySlot.tscn")
		slot.slot_index = i
		slot.set_item(items[i])
		grid.add_child(slot)
