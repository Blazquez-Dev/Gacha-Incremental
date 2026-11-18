extends Node2D

@export var enemy_scene: PackedScene
@export var gate_max_hp := 100

var gate_hp := 0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var hp_label: Label = $UI/HpLabel
@onready var game_over_panel: Control = $UI/GameOver
@onready var restart_button: Button = $UI/GameOver/RestartButton

func _ready():
	gate_hp = gate_max_hp
	_update_label()
	game_over_panel.hide()
	restart_button.pressed.connect(_on_restart)
	spawn_timer.wait_time = 1.0
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(60, 1020), -50)
	enemy.reached_gate.connect(_on_enemy_reached_gate)
	add_child(enemy)

func _on_enemy_reached_gate(damage):
	gate_hp = max(gate_hp - damage, 0)
	_update_label()
	if gate_hp == 0:
		_game_over()

func _update_label():
	hp_label.text = "Portón: %d / %d" % [gate_hp, gate_max_hp]

func _game_over():
	spawn_timer.stop()
	get_tree().paused = true
	game_over_panel.show()

func _on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
