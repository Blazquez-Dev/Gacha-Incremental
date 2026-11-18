extends Area2D

var speed := 1200.0
var damage := 1

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	position.y -= speed * delta
	if position.y < -100:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(damage)
		queue_free()
