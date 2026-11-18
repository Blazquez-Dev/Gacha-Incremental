extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.5

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = fire_rate
	timer.timeout.connect(_shoot)
	timer.start()

func _shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, -50)
	get_parent().add_child(bullet)
