extends Node2D

const SHEET = preload("res://assets/heroe1/fire-vortex-64.png")
const FRAME_SIZE := 64
const FRAME_COUNT := 12
const FPS := 30.0
const VISUAL_SCALE := 0.8
const GROW_TIME := 0.5
const HOLD_TIME := 0.4
const FADE_TIME := 0.2
const TICK_TIME := 0.2      # cada cuántos segundos hace daño

var radius := 200.0
var damage := 1             # daño por pulso (lo pone main.gd)

var sprite: AnimatedSprite2D
var elapsed := 0.0
var tick_timer := 0.0

func _ready():
	z_index = 5

	var frames = SpriteFrames.new()
	frames.set_animation_loop("default", true)
	frames.set_animation_speed("default", FPS)
	for i in FRAME_COUNT:
		var atlas = AtlasTexture.new()
		atlas.atlas = SHEET
		atlas.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
		frames.add_frame("default", atlas)

	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ZERO
	add_child(sprite)

	var target_scale = Vector2.ONE * (radius * 2.0 * VISUAL_SCALE / FRAME_SIZE)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", target_scale, GROW_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(sprite, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(queue_free)

	sprite.play("default")

func _process(delta):
	# El daño solo se aplica mientras crece y se mantiene, no al desvanecerse
	if elapsed >= GROW_TIME + HOLD_TIME:
		return
	elapsed += delta
	tick_timer += delta
	if tick_timer >= TICK_TIME:
		tick_timer -= TICK_TIME
		_damage_tick()

func _damage_tick():
	# Radio actual = lo que se ve en pantalla en este momento
	var current_radius = sprite.scale.x * FRAME_SIZE * 0.5
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(global_position) <= current_radius:
			enemy.take_damage(damage)
