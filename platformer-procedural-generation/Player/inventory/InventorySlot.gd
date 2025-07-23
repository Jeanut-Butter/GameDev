extends PanelContainer

class_name InventorySlot

@export var type: ItemData.Type

signal item_changed(item_data: ItemData)

signal weapon
signal gun
signal knife
signal no_weapon

var slot_index := -1

func init(t: ItemData.Type, cms: Vector2, index: int) -> void:
	type = t
	custom_minimum_size = cms
	slot_index = index

func _can_drop_data(at_position: Vector2, data: Variant):
	if data is InventoryItem:
		if type == ItemData.Type.MAIN:
			if get_child_count() == 0:
				return true
			else:
				if type == data.get_parent().type:
					return true
			return get_child(0).data.type == data.data.type
		else: 
			return data.data.type == type
	return false
func _drop_data(at_position: Vector2, data: Variant):
	if get_child_count() > 0:
		var item := get_child(0)
		if item == data:
			return
		item.reparent(data.get_parent())
	data.reparent(self)
	
	if data is InventoryItem and data.data:
		item_changed.emit(data.data)
		if slot_index == 0 and data is InventoryItem and data.data:
			emit_signal("item_changed")
			if data.data.type == ItemData.Type.WEAPON:
				emit_signal("weapon")
				print("weapon")
				if data.data.name == "Pistol":
					emit_signal("gun")
					print("gun")
				if data.data.name == "Knife":
					emit_signal('knife')
					print("knife")
			else:
				emit_signal("no_weapon")
				print("no weapon")
