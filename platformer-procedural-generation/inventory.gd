extends Node2D

var items: Array = []

func add_item(item_data: Dictionary) -> void:
	if item_data == null:
		return
	items.append(item_data)

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items.remove_at(index)

func get_items() -> Array:
	return items
