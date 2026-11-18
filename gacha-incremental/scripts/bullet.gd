extends Area2D

var speed := 1200.0
var damage := 1
var direction := Vector2.UP

func _ready():
	rotation = direction.angle() + PI / 2
	area_entered.connect(_on_area_entered)

func _process(delta):
	position += direction * speed * delta
	if position.y < -100 or position.y > 2000 or position.x < -100 or position.x > 1180:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(damage)
		queue_free()
