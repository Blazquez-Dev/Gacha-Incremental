extends Area2D

var speed := 1200.0
var damage := 1.0
var direction := Vector2.UP
var color := Color(1.0, 0.7, 0.2)   # color base; cada héroe podrá tener el suyo
var burn_dps := 0.0
var slow := 0.0

const BURN_TIME := 3.0
const SLOW_TIME := 2.0

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
		if not area.dead:
			if burn_dps > 0.0:
				area.apply_burn(burn_dps, BURN_TIME)
			if slow > 0.0:
				area.apply_slow(slow, SLOW_TIME)
		queue_free()

func _draw():
	# El frente de la bala apunta hacia -Y; la estela va hacia +Y
	var glow = Color(color, 0.25)
	var mid = Color(color, 0.7)
	var core = color.lerp(Color.WHITE, 0.8)

	# Estela: triángulo que se desvanece hacia atrás
	draw_polygon(
		PackedVector2Array([Vector2(-5, 6), Vector2(5, 6), Vector2(0, 60)]),
		PackedColorArray([Color(color, 0.5), Color(color, 0.5), Color(color, 0.0)])
	)

	# Resplandor, cuerpo y núcleo, de fuera hacia dentro
	_capsule(14.0, 20.0, glow)
	_capsule(12.0, 12.0, mid)
	_capsule(10.0, 5.0, core)

func _capsule(half_len: float, width: float, c: Color):
	draw_line(Vector2(0, -half_len), Vector2(0, half_len), c, width)
	draw_circle(Vector2(0, -half_len), width / 2.0, c)
	draw_circle(Vector2(0, half_len), width / 2.0, c)
