extends Area2D

signal reached_gate(damage)
signal died(xp)

var speed := 150.0
var hp := 3
var damage := 10
var xp_value := 1
var dead := false

func _ready():
	add_to_group("enemies")

func _process(delta):
	position.y += speed * delta
	if position.y > 1480:
		reached_gate.emit(damage)
		queue_free()

func take_damage(amount):
	if dead:
		return
	hp -= amount
	if hp <= 0:
		dead = true
		died.emit(xp_value)
		queue_free()
