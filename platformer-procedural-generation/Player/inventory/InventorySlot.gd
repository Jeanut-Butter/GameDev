extends TextureButton

@export var slot_index: int = -1
var item: ItemData = null

func set_item(new_item: ItemData) -> void:
	item = new_item
	# If you have a TextureRect child to show the icon:
	if has_node("Icon") and item.icon:
		$Icon.texture = item.icon
	if has_node("Quantity") and item.stackable:
		$Quantity.text = str(item.quantity)

func _on_mouse_entered():
	var tooltip = get_node("/root/InventoryUI/Panel/Tooltip")
	tooltip.text = "Item Name: " + item.name + "\nDescription: " + item.description
	tooltip.visible = true

func _on_mouse_exited():
	get_node("/root/InventoryUI/Panel/Tooltip").visible = false

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on item: %s"% item.name)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Use or equip item!")


func get_drag_data(position):
	var drag_preview = TextureRect.new()
	drag_preview.texture = item.icon
	set_drag_preview(drag_preview)
	return item

func can_drop_data(position, data):
	return true

func drop_data(position, data):
	var temp = item
	item = data
