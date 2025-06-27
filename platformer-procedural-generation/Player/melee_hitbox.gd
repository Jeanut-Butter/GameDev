extends Area2D

@export var attack_damage := 1

func _on_MeleeHitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
