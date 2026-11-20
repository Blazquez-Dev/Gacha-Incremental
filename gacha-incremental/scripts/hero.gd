extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.5
@export var damage := 1

@onready var timer: Timer = $Timer
@onready var flash: Polygon2D = $Flash

var flash_tween: Tween

func _ready():
	flash.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(-26, -26), Vector2(-8, -22),
		Vector2(0, -70), Vector2(8, -22), Vector2(26, -26),
		Vector2(10, 0), Vector2(0, 8)
	])
	flash.color = Color(1.0, 0.85, 0.3)
	flash.hide()
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
	var origin = global_position
	var bullet = bullet_scene.instantiate()
	var travel_time = origin.distance_to(target.global_position) / bullet.speed
	var aim_point = target.global_position + Vector2(0, target.speed * travel_time)
	bullet.position = origin
	bullet.direction = (aim_point - origin).normalized()
	bullet.damage = damage
	get_parent().add_child(bullet)
	_show_flash(bullet.direction)

func _show_flash(dir: Vector2):
	if flash_tween:
		flash_tween.kill()
	flash.rotation = dir.angle() + PI / 2
	flash.scale = Vector2(0.6, 0.6)
	flash.modulate = Color(1, 1, 1, 1)
	flash.show()
	flash_tween = create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property(flash, "scale", Vector2(1.2, 1.2), 0.08)
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.08)
	flash_tween.chain().tween_callback(flash.hide)
