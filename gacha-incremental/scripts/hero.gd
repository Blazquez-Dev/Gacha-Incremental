extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.5
@export var damage := 1.0

var burn_dps := 0.0
var slow := 0.0

# Apuntado manual
var manual_aim := false
var aim_target := Vector2.ZERO

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

func start_manual_aim(pos: Vector2):
	manual_aim = true
	aim_target = pos
	queue_redraw()

func _process(_delta):
	if not manual_aim:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		aim_target = get_global_mouse_position()
		# No se puede apuntar hacia abajo ni a ras del héroe
		aim_target.y = minf(aim_target.y, global_position.y - 50.0)
	else:
		manual_aim = false  # soltó el dedo: vuelve el apuntado automático
	queue_redraw()

func _draw():
	if not manual_aim:
		return
	var end = to_local(aim_target)
	draw_dashed_line(Vector2.ZERO, end, Color(1, 1, 1, 0.35), 3.0, 16.0)
	draw_circle(end, 18.0, Color(1, 1, 1, 0.15))
	draw_arc(end, 18.0, 0.0, TAU, 24, Color(1, 1, 1, 0.6), 3.0)

func _get_target():
	var target = null
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.position.y < 0:
			continue
		if target == null or enemy.position.y > target.position.y:
			target = enemy
	return target

func _shoot():
	var origin = global_position
	var target = null
	if not manual_aim:
		target = _get_target()
		if target == null:
			return

	var bullet = bullet_scene.instantiate()
	var dir: Vector2
	if manual_aim:
		dir = (aim_target - origin).normalized()
	else:
		var travel_time = origin.distance_to(target.global_position) / bullet.speed
		var aim_point = target.global_position + Vector2(0, target.get_speed() * travel_time)
		dir = (aim_point - origin).normalized()

	bullet.position = origin
	bullet.direction = dir
	bullet.damage = damage
	bullet.burn_dps = burn_dps
	bullet.slow = slow
	bullet.color = _bullet_color()
	get_parent().add_child(bullet)
	_show_flash(dir)

func _bullet_color() -> Color:
	if burn_dps > 0.0 and slow > 0.0:
		return Color(0.8, 0.5, 1.0)
	if burn_dps > 0.0:
		return Color(1.0, 0.35, 0.1)
	if slow > 0.0:
		return Color(0.4, 0.8, 1.0)
	return Color(1.0, 0.7, 0.2)

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
