extends Node2D

var speed := 1200.0

func _process(delta):
	position.y -= speed * delta
	if position.y < -100:
		queue_free()
