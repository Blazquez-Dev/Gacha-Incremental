extends Node2D

@export var enemy_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.wait_time = 1.0
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(60, 1020), -50)
	add_child(enemy)
