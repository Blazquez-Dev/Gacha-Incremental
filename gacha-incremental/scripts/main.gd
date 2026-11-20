extends Node2D

@export var enemy_scene: PackedScene
@export var gate_max_hp := 100
@export var skill_cooldown := 8.0
@export var grenade_radius := 220.0
@export var grenade_damage := 1
@export var basic_rate := 0.4             # básicos por segundo en el nivel 1
@export var basic_rate_per_level := 0.2   # cuánto sube por nivel
@export var max_basic := 60               # tope de básicos vivos (rendimiento)
@export var xp_base := 10      # XP para pasar del nivel 1 al 2
@export var xp_step := 3.0     # aumento lineal por nivel
@export var xp_curve := 0.15   # aceleración: cuánto más cuesta cada nivel que el anterior
@export var shield_amount := 25
var gate_shield := 0

const ExplosionScript = preload("res://scripts/explosion.gd")

var aiming := false
var skill_ready := true
var skill_tween: Tween
var gate_hp := 0
var xp := 0
var level := 1
var choosing := false
var current_options := []
var barricade_base_pos := Vector2.ZERO
var flash_tween: Tween
var shake_tween: Tween
var elapsed_time := 0.0

var upgrade_pool := [
	{"id": "damage", "title": "Daño", "desc": "Cada bala hace más daño"},
	{"id": "rate", "title": "Cadencia", "desc": "Disparas más rápido"},
	{"id": "repair", "title": "Reparar muro", "desc": "Restaura el 40% de su vida máxima"},
	{"id": "gate", "title": "Muro reforzado", "desc": "+30 de vida máxima"},
	{"id": "shield", "title": "Escudo del muro", "desc": ""},
	{"id": "fire", "title": "Balas ígneas", "desc": ""},
	{"id": "ice", "title": "Balas congelantes", "desc": ""},
]
var special_timers := {}

var specials := [
	{
		"id": "runner",
		"scene": "res://scenes/runner.tscn",
		"hp": 3, "speed": 260.0, "damage": 8, "xp": 2,
		"min_level": 1, "full_level": 50,   # de aquí a aquí va escalando
		"chance_start": 0.50, "chance_end": 2.00,
		"max_start": 1, "max_end": 10,
		"roll_every": 3.0,                  # cada cuántos segundos tira el dado
	},
	{
		"id": "tank",
		"scene": "res://scenes/tank.tscn",
		"hp": 12, "speed": 80.0, "damage": 25, "xp": 4,
		"min_level": 3, "full_level": 60,
		"chance_start": 0.2, "chance_end": 1,
		"max_start": 1, "max_end": 6,
		"roll_every": 3,
	},
	{
		"id": "boss1",
		"scene": "res://scenes/boss1.tscn",
		"hp": 20, "speed": 30.0, "damage": 45, "xp": 10,
		"min_level": 5, "full_level": 60,
		"chance_start": 1, "chance_end": 1,
		"max_start": 1, "max_end": 2,
		"roll_every": 5,
	},
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
@onready var skill_button: Button = $UI/SkillButton
@onready var skill_cooldown_bar: TextureProgressBar = $UI/SkillButton/CooldownBar
@onready var time_label: Label = $UI/TimeLabel

func _ready():
	_update_time_label()
	barricade_base_pos = barricade.position
	gate_hp = gate_max_hp
	_update_hp_label()
	_update_xp_ui()
	game_over_panel.hide()
	level_up_panel.hide()
	restart_button.pressed.connect(_on_restart)
	for i in option_buttons.size():
		option_buttons[i].pressed.connect(_on_option_chosen.bind(i))
	skill_button.pressed.connect(_on_skill_pressed)
	skill_cooldown_bar.max_value = 100.0
	skill_cooldown_bar.value = 100.0
	_update_spawn_rate()
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _update_spawn_rate():
	var rate = basic_rate + basic_rate_per_level * (level - 1)
	spawn_timer.wait_time = 1.0 / rate

func _spawn_enemy():
	if _alive_of("basic") >= max_basic:
		return
	var enemy = enemy_scene.instantiate()
	enemy.set_meta("type_id", "basic")
	_add_enemy(enemy)


func _process(delta):
	elapsed_time += delta
	_update_time_label()
	for s in specials:
		if level < s["min_level"]:
			continue
		var id = s["id"]
		special_timers[id] = special_timers.get(id, 0.0) + delta
		if special_timers[id] >= s["roll_every"]:
			special_timers[id] -= s["roll_every"]
			_try_spawn_special(s)
			
func _update_time_label():
	var minutes = floori(elapsed_time / 60.0)
	var seconds = int(elapsed_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _try_spawn_special(s):
	# t va de 0 (nivel inicial) a 1 (nivel final)
	var t = clampf(float(level - s["min_level"]) / float(s["full_level"] - s["min_level"]), 0.0, 1.0)
	var chance = lerpf(s["chance_start"], s["chance_end"], t)
	var max_alive = roundi(lerpf(s["max_start"], s["max_end"], t))

	if _alive_of(s["id"]) >= max_alive:
		return
	if randf() > chance:
		return

	var enemy = load(s["scene"]).instantiate()
	enemy.hp = s["hp"]
	enemy.speed = s["speed"]
	enemy.damage = s["damage"]
	enemy.xp_value = s["xp"]
	enemy.set_meta("type_id", s["id"])
	_add_enemy(enemy)

func _add_enemy(enemy):
	enemy.position = Vector2(randf_range(130, 950), -50)
	enemy.reached_gate.connect(_on_enemy_reached_gate)
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _alive_of(id: String) -> int:
	var n := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.get_meta("type_id", "") == id:
			n += 1
	return n

func _on_enemy_reached_gate(damage):
	var remaining = damage
	if gate_shield > 0:
		var absorbed = mini(gate_shield, remaining)
		gate_shield -= absorbed
		remaining -= absorbed
	gate_hp = max(gate_hp - remaining, 0)
	_update_hp_label()
	# Destello azul si el escudo paró todo el golpe, rojo si no
	_hit_barricade(Color(0.3, 0.6, 1.0) if remaining == 0 else Color(1.0, 0.25, 0.25))
	if gate_hp == 0:
		_game_over()
		


func _on_enemy_died(amount):
	xp += amount
	_update_xp_ui()
	_check_level_up()

func xp_needed():
	var n = level - 1
	return roundi(xp_base + xp_step * n + xp_curve * n * n)

func _check_level_up():
	if choosing or xp < xp_needed():
		return
	xp -= xp_needed()
	level += 1
	_update_spawn_rate()
	_update_xp_ui()
	_show_options()

func _show_options():
	choosing = true
	var pool = upgrade_pool.duplicate()
	pool.shuffle()
	current_options = pool.slice(0, 3)
	for i in option_buttons.size():
		var opt = current_options[i]
		option_buttons[i].text = opt["title"] + "\n" + _option_desc(opt)
	level_up_panel.show()
	get_tree().paused = true

func _option_desc(opt) -> String:
	match opt["id"]:
		"shield":
			return "Absorbe %d de daño antes que la vida del muro" % shield_amount
		"fire":
			if hero.burn_dps <= 0.0:
				return "Daño residual de 0.2 por segundo"
			return "Daño residual: de %.1f a %.1f por segundo" % [hero.burn_dps, hero.burn_dps + 0.1]
		"ice":
			if hero.slow <= 0.0:
				return "Ralentiza a los enemigos un 5%"
			return "Ralentización: de %d%% a %d%%" % [roundi(hero.slow * 100), roundi((hero.slow + 0.02) * 100)]
	return opt["desc"]

func _on_option_chosen(index):
	_apply_upgrade(current_options[index]["id"])
	level_up_panel.hide()
	get_tree().paused = false
	choosing = false
	_check_level_up()

func _apply_upgrade(id):
	match id:
		"damage":
			hero.damage += 0.4
		"rate":
			hero.fire_rate /= 1.1
			hero.timer.wait_time = hero.fire_rate
		"repair":
			gate_hp = min(gate_hp + roundi(gate_max_hp * 0.4), gate_max_hp)
		"gate":
			gate_max_hp += 30
		"shield":
			gate_shield += shield_amount
		"fire":
			hero.burn_dps = 0.2 if hero.burn_dps <= 0.0 else hero.burn_dps + 0.1
		"ice":
			hero.slow = 0.05 if hero.slow <= 0.0 else minf(hero.slow + 0.02, 0.8)
	_update_hp_label()

func _update_hp_label():
	hp_label.text = "%d / %d" % [gate_hp, gate_max_hp]
	if gate_shield > 0:
		hp_label.text += " (+%d)" % gate_shield
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

func _hit_barricade(flash_color := Color(1.0, 0.25, 0.25)):
	if flash_tween:
		flash_tween.kill()
	barricade.modulate = flash_color
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

func _on_skill_pressed():
	if not skill_ready:
		return
	# Pulsar activa el modo apuntado; volver a pulsar lo cancela
	aiming = not aiming
	skill_button.modulate = Color(1.0, 0.9, 0.4) if aiming else Color.WHITE

func _unhandled_input(event):
	# Con la granada en mano, el toque lanza la granada (no apunta el arma)
	if aiming:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var pos = get_global_mouse_position()
			if pos.y > 1380:  # no se puede lanzar detrás del portón
				return
			_throw_grenade(pos)
			get_viewport().set_input_as_handled()
		return

	# Si no, tocar el campo empieza a apuntar el arma
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hero.start_manual_aim(get_global_mouse_position())

func _throw_grenade(pos: Vector2):
	aiming = false
	skill_button.modulate = Color.WHITE
	skill_ready = false

	_explode(pos)

	# El enfriamiento empieza al lanzar, no al pulsar el botón
	skill_cooldown_bar.value = 0.0
	skill_tween = create_tween()
	skill_tween.tween_property(skill_cooldown_bar, "value", 100.0, skill_cooldown)
	skill_tween.tween_callback(_on_skill_ready)

func _explode(pos: Vector2):
	var boom = ExplosionScript.new()
	boom.radius = grenade_radius
	boom.damage = grenade_damage
	boom.position = pos
	add_child(boom)

func _on_skill_ready():
	skill_ready = true
