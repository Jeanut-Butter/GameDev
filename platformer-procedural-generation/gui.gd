extends CanvasLayer

@export var invSize = 16
@export var visibility := true
var itemsLoad = [
	"res://Player/inventory/Items/Pistol.tres",
	"res://Player/inventory/Items/Knife.tres",
	"res://Player/inventory/Items/Bullet.tres"
]

please be fixed
func _ready():
	for i in invSize:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(117,54), i)  # <-- pass the index!
		%Inv.add_child(slot)
	
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
