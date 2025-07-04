extends PanelContainer

class_name InventorySlot

@export var type: ItemData.Type

func init(t: ItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms
