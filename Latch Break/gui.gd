extends CanvasLayer

@export var invSize = 16
@export var visibility := true
var itemsLoad = [
]

func _ready():
	for i in invSize:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(117,54), i)  # <-- pass the index!
		%Inv.add_child(slot)
	# fish
	for i in itemsLoad.size():
		var item := InventoryItem.new()
		item.init(load(itemsLoad[i]))
		%Inv.get_child(i).add_child(item)

func _process(delta):
	if Input.is_action_just_pressed("InvToggle"):
		visibility = !visibility
		toggleInv()

func toggleInv():
	$Panel.visible = !$Panel.visible
	$Panel/Inv.visible = !$Panel/Inv.visible

func add_item_to_inventory(item_data: ItemData) -> bool:
	for slot in %Inv.get_children():
		if slot.get_child_count() == 0:
			var item := InventoryItem.new()
			item.init(item_data)
			slot.add_child(item)
			return true
	return false # inventory full
