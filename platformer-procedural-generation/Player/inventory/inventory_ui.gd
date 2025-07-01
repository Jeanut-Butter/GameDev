extends Control

@onready var grid: GridContainer = $Panel/GridContainer

func populate_inventory(items: Array):
	for i in range(items.size()):
		var slot = preload("res://Player/inventory/InventorySlot.tscn")
		slot.slot_index = i
		slot.set_item(items[i])
		grid.add_child(slot)
