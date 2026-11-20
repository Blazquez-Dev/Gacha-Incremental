extends Area2D

signal reached_gate(damage)
signal died(xp)

var speed := 150.0
var hp := 3.0
var damage := 10
var xp_value := 1
var color := Color.WHITE
var dead := false

# Efectos de estado
var burn_dps := 0.0
var burn_time := 0.0
var slow_amount := 0.0
var slow_time := 0.0
var base_modulate := Color.WHITE

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	add_to_group("enemies")
	base_modulate = color.lerp(Color.WHITE, 0.5)
	sprite.modulate = base_modulate
	sprite.play("walk")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("walk")

func _process(delta):
	if burn_time > 0.0:
		burn_time -= delta
		take_damage(burn_dps * delta)
		if burn_time <= 0.0:
			_update_tint()
	if dead:
		return
	if slow_time > 0.0:
		slow_time -= delta
		if slow_time <= 0.0:
			slow_amount = 0.0
			_update_tint()

	position.y += get_speed() * delta
	if position.y > 1380:
		reached_gate.emit(damage)
		queue_free()

# Velocidad real, con la ralentización aplicada
func get_speed() -> float:
	return speed * (1.0 - slow_amount)

func apply_burn(dps: float, duration: float):
	if dead:
		return
	burn_dps = dps
	burn_time = duration
	_update_tint()

func apply_slow(amount: float, duration: float):
	if dead:
		return
	slow_amount = amount
	slow_time = duration
	_update_tint()

func _update_tint():
	var c = base_modulate
	if slow_time > 0.0:
		c = c.lerp(Color(0.4, 0.75, 1.0), 0.6)
	if burn_time > 0.0:
		c = c.lerp(Color(1.0, 0.5, 0.15), 0.5)
	sprite.modulate = c

func take_damage(amount):
	if dead:
		return
	hp -= amount
	if hp <= 0.001:  # margen por los decimales
		dead = true
		died.emit(xp_value)
		queue_free()
