extends Area2D

@export var speed = 400
var direction = Vector2.ZERO

func shoot(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle() + PI

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()  
