extends Area2D

var speed := 150.0
var hp := 3

func _ready():
	add_to_group("enemies")

func _process(delta):
	position.y += speed * delta
	if position.y > 1480:
		queue_free()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
