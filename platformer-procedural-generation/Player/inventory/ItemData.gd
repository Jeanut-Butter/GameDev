extends Resource
class_name ItemData

enum Type {GRAPPLE, AMMO, WEAPON, ACCESSORY, MAIN}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
