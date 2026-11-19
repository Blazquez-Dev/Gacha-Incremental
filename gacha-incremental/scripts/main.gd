extends Node2D

@export var enemy_scene: PackedScene
@export var gate_max_hp := 100

var gate_hp := 0
var xp := 0
var level := 1
var choosing := false
var current_options := []
var barricade_base_pos := Vector2.ZERO
var flash_tween: Tween
var shake_tween: Tween

var upgrade_pool := [
	{"id": "damage", "title": "Daño +1", "desc": "Cada bala hace más daño"},
	{"id": "rate", "title": "Cadencia +15%", "desc": "Disparas más rápido"},
	{"id": "repair", "title": "Reparar portón", "desc": "Recupera 30 de vida"},
	{"id": "gate", "title": "Portón reforzado", "desc": "+25 de vida máxima y cura 25"},
]

@onready var hero = $Hero
@onready var spawn_timer: Timer = $SpawnTimer
@onready var level_label: Label = $UI/LevelLabel
@onready var xp_bar: ProgressBar = $UI/XpBar
@onready var level_up_panel: Control = $UI/LevelUp
@onready var option_buttons := [$UI/LevelUp/Option1, $UI/LevelUp/Option2, $UI/LevelUp/Option3]
@onready var game_over_panel: Control = $UI/GameOver
@onready var restart_button: Button = $UI/GameOver/RestartButton
@onready var hp_label: Label = $UI/GateBar/HpLabel
@onready var gate_bar: ProgressBar = $UI/GateBar
@onready var barricade: Sprite2D = $Barricade

func _ready():
	barricade_base_pos = barricade.position
	gate_hp = gate_max_hp
	_update_hp_label()
	_update_xp_ui()
	game_over_panel.hide()
	level_up_panel.hide()
	restart_button.pressed.connect(_on_restart)
	for i in option_buttons.size():
		option_buttons[i].pressed.connect(_on_option_chosen.bind(i))
	spawn_timer.wait_time = 1.0
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(130, 950), -50)
	enemy.reached_gate.connect(_on_enemy_reached_gate)
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_reached_gate(damage):
	gate_hp = max(gate_hp - damage, 0)
	_update_hp_label()
	_hit_barricade()
	if gate_hp == 0:
		_game_over()

func _on_enemy_died(amount):
	xp += amount
	_update_xp_ui()
	_check_level_up()

func xp_needed():
	return 4 + level * 2

func _check_level_up():
	if choosing or xp < xp_needed():
		return
	xp -= xp_needed()
	level += 1
	_update_xp_ui()
	_show_options()

func _show_options():
	choosing = true
	var pool = upgrade_pool.duplicate()
	pool.shuffle()
	current_options = pool.slice(0, 3)
	for i in option_buttons.size():
		var opt = current_options[i]
		option_buttons[i].text = opt["title"] + "\n" + opt["desc"]
	level_up_panel.show()
	get_tree().paused = true

func _on_option_chosen(index):
	_apply_upgrade(current_options[index]["id"])
	level_up_panel.hide()
	get_tree().paused = false
	choosing = false
	_check_level_up()

func _apply_upgrade(id):
	match id:
		"damage":
			hero.damage += 1
		"rate":
			hero.fire_rate *= 0.85
			hero.timer.wait_time = hero.fire_rate
		"repair":
			gate_hp = min(gate_hp + 30, gate_max_hp)
		"gate":
			gate_max_hp += 25
			gate_hp = min(gate_hp + 25, gate_max_hp)
	_update_hp_label()

func _update_hp_label():
	hp_label.text = "%d / %d" % [gate_hp, gate_max_hp]
	gate_bar.max_value = gate_max_hp
	gate_bar.value = gate_hp

func _update_xp_ui():
	level_label.text = "Nivel %d" % level
	xp_bar.max_value = xp_needed()
	xp_bar.value = xp

func _game_over():
	spawn_timer.stop()
	get_tree().paused = true
	game_over_panel.show()

func _on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _hit_barricade():
	# Flash rojo
	if flash_tween:
		flash_tween.kill()
	barricade.modulate = Color(1.0, 0.25, 0.25)
	flash_tween = create_tween()
	flash_tween.tween_property(barricade, "modulate", Color.WHITE, 0.3)

	# Vibración
	if shake_tween:
		shake_tween.kill()
	barricade.position = barricade_base_pos
	shake_tween = create_tween()
	for i in 5:
		var offset = Vector2(randf_range(-8, 8), randf_range(-4, 4))
		shake_tween.tween_property(barricade, "position", barricade_base_pos + offset, 0.03)
	shake_tween.tween_property(barricade, "position", barricade_base_pos, 0.03)
