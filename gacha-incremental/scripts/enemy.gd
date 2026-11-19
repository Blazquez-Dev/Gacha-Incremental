extends Area2D

signal reached_gate(damage)
signal died(xp)

var speed := 150.0
var hp := 3
var damage := 10
var xp_value := 1
var color := Color.WHITE
var dead := false

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	add_to_group("enemies")
	sprite.modulate = color.lerp(Color.WHITE, 0.5)
	sprite.play("walk")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("walk")

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
