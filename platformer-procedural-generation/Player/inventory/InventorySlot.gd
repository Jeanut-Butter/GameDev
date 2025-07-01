extends TextureButton

@export var slot_index: int = -1
var item_data: Resource = null

func set_item(data: ItemData) -> void:
	item_data = data
	texture_normal = data.icon

#func _on_mouse_entered():
	#if item_data():
		#show_tooltip(item_data)
#
#func _on_mouse_exited():
	#hide_tooltip()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on item: %s"% item_data.name)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Use or equip item!")
