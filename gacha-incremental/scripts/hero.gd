extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.5

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = fire_rate
	timer.timeout.connect(_shoot)
	timer.start()

func _get_target():
	var target = null
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.position.y < 0:
			continue
		if target == null or enemy.position.y > target.position.y:
			target = enemy
	return target

func _shoot():
	var target = _get_target()
	if target == null:
		return
	var origin = global_position + Vector2(0, -50)
	var bullet = bullet_scene.instantiate()
	var travel_time = origin.distance_to(target.global_position) / bullet.speed
	var aim_point = target.global_position + Vector2(0, target.speed * travel_time)
	bullet.position = origin
	bullet.direction = (aim_point - origin).normalized()
	get_parent().add_child(bullet)
