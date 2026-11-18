extends Area2D

signal reached_gate(damage)

var speed := 150.0
var hp := 3
var damage := 10

func _ready():
	add_to_group("enemies")

func _process(delta):
	position.y += speed * delta
	if position.y > 1480:
		reached_gate.emit(damage)
		queue_free()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
