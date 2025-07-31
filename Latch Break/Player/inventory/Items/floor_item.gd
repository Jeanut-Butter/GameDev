extends Area2D

@export var item_data: ItemData

func _ready():
	if item_data and $Sprite2D:
		$Sprite2D.texture = item_data.texture
		
		var shape = $CollisionShape2D.shape
		if shape is RectangleShape2D and item_data.texture:
			var size = item_data.texture.get_size()
			shape.extents = size / 2.0  # RectangleShape2D extents are half-size
			$CollisionShape2D.position = $Sprite2D.position
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pick_up(item_data)
		queue_free()
