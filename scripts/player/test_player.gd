extends CharacterBody2D

signal hard_landed
signal dash_started

const IDLE_FRAME_COUNT := 16
const WALK_FRAME_COUNT := 12
const AIR_FRAME_COUNT := 12
const LANDING_FRAME_COUNT := 8
const RUN_FRAME_COUNT := 16
const DASH_FRAME_COUNT := 12
const LANDING_FRAME_DURATION := 0.10
const GROUND_IMPACT_DURATION := 0.07
const DASH_FRAME_DURATION := 0.05

@export var move_speed := 260.0
@export var run_speed := 430.0
@export var run_start_speed := 400.0
@export var dash_speed := 660.0
@export var acceleration := 1800.0
@export var jump_velocity := -560.0
@export var gravity := 1500.0
@export var hard_landing_speed := 700.0

var wasd_jump_pressed := false
var animation_time := 0.0
var landing_animation_time := 0.0
var ground_impact_time := 0.0
var fast_fall_started := false
var is_landing := false
var is_ground_impact := false
var is_dashing := false
var dash_animation_time := 0.0
var dash_direction := 1.0
var wasd_dash_pressed := false

@onready var raccoon_sprite: Sprite2D = $RaccoonSprite
@onready var walking_sprite: Sprite2D = $WalkingSprite
@onready var air_sprite: Sprite2D = $AirSprite
@onready var landing_sprite: Sprite2D = $LandingSprite
@onready var running_sprite: Sprite2D = $RunningSprite
@onready var ground_impact_sprite: Sprite2D = $GroundImpactSprite
@onready var dash_sprite: Sprite2D = $DashSprite

func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity.x = dash_direction * dash_speed
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		_update_animation(delta)
		return

	if is_landing:
		velocity.x = 0.0
		move_and_slide()
		_update_animation(delta)
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_physical_key_pressed(KEY_S):
			velocity.y += gravity * delta
			fast_fall_started = true

	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_physical_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction += 1.0
	direction = clampf(direction, -1.0, 1.0)
	var is_running_input := Input.is_physical_key_pressed(KEY_CTRL)
	var target_speed := run_speed if is_running_input else move_speed
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)

	var dash_just_pressed := Input.is_physical_key_pressed(KEY_J) and not wasd_dash_pressed
	if dash_just_pressed and is_on_floor() and absf(velocity.x) >= run_speed:
		is_dashing = true
		dash_animation_time = 0.0
		dash_direction = signf(velocity.x)
		dash_started.emit()
		wasd_dash_pressed = true
		_update_animation(0.0)
		return
	wasd_dash_pressed = Input.is_physical_key_pressed(KEY_J)

	var wasd_jump_just_pressed := Input.is_physical_key_pressed(KEY_W) and not wasd_jump_pressed
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or wasd_jump_just_pressed:
		if is_on_floor():
			velocity.y = jump_velocity
			fast_fall_started = false
	wasd_jump_pressed = Input.is_physical_key_pressed(KEY_W)

	var was_airborne := not is_on_floor()
	var downward_speed_before_landing := velocity.y
	move_and_slide()
	var landed_hard := was_airborne and is_on_floor() and fast_fall_started and downward_speed_before_landing >= hard_landing_speed
	if landed_hard:
		is_landing = true
		is_ground_impact = false
		landing_animation_time = 0.0
		velocity.x = 0.0
		hard_landed.emit()
	elif was_airborne and is_on_floor():
		is_ground_impact = true
		ground_impact_time = 0.0
	_update_animation(delta)

func _update_animation(delta: float) -> void:
	animation_time += delta
	if is_dashing:
		dash_animation_time += delta
		if dash_animation_time >= DASH_FRAME_DURATION * DASH_FRAME_COUNT:
			is_dashing = false
			dash_animation_time = 0.0
	if is_landing:
		landing_animation_time += delta
		if landing_animation_time >= LANDING_FRAME_DURATION * LANDING_FRAME_COUNT:
			is_landing = false
			fast_fall_started = false
			landing_animation_time = 0.0
	if is_ground_impact:
		ground_impact_time += delta
		if ground_impact_time >= GROUND_IMPACT_DURATION:
			is_ground_impact = false
			ground_impact_time = 0.0

	var is_grounded := is_on_floor()
	var is_playing_landing := is_landing
	var is_playing_ground_impact := is_ground_impact and not is_playing_landing
	var is_playing_dash := is_dashing
	var is_running := is_grounded and absf(velocity.x) >= run_start_speed
	var is_walking := is_grounded and absf(velocity.x) > 10.0 and not is_running
	var is_idle := is_grounded and not is_walking and not is_running and not is_playing_landing and not is_playing_ground_impact and not is_playing_dash
	var is_airborne := not is_grounded and not is_playing_landing and not is_playing_ground_impact and not is_playing_dash
	var entered_idle := is_idle and not raccoon_sprite.visible
	if entered_idle:
		animation_time = 0.0
	var active_sprite := dash_sprite if is_playing_dash else ground_impact_sprite if is_playing_ground_impact else landing_sprite if is_playing_landing else air_sprite if is_airborne else running_sprite if is_running else walking_sprite if is_walking else raccoon_sprite
	raccoon_sprite.visible = active_sprite == raccoon_sprite
	walking_sprite.visible = active_sprite == walking_sprite
	air_sprite.visible = active_sprite == air_sprite
	landing_sprite.visible = active_sprite == landing_sprite
	running_sprite.visible = active_sprite == running_sprite
	ground_impact_sprite.visible = active_sprite == ground_impact_sprite
	dash_sprite.visible = active_sprite == dash_sprite
	if is_idle:
		if entered_idle:
			raccoon_sprite.frame = 0
		else:
			raccoon_sprite.frame = int(animation_time * 8.0) % IDLE_FRAME_COUNT
	if is_walking:
		walking_sprite.frame = int(animation_time * 10.0) % WALK_FRAME_COUNT
	if is_airborne:
		air_sprite.frame = int(animation_time * 10.0) % AIR_FRAME_COUNT
	if is_playing_landing:
		landing_sprite.frame = mini(int(landing_animation_time / LANDING_FRAME_DURATION), LANDING_FRAME_COUNT - 1)
	if is_playing_ground_impact:
		ground_impact_sprite.frame = 0
	if is_running:
		running_sprite.frame = int(animation_time * 12.0) % RUN_FRAME_COUNT
	if is_playing_dash:
		dash_sprite.frame = mini(int(dash_animation_time / DASH_FRAME_DURATION), DASH_FRAME_COUNT - 1)

	if absf(velocity.x) > 10.0:
		raccoon_sprite.flip_h = velocity.x < 0.0
		walking_sprite.flip_h = velocity.x < 0.0
		air_sprite.flip_h = velocity.x < 0.0
		landing_sprite.flip_h = velocity.x < 0.0
		running_sprite.flip_h = velocity.x < 0.0
		ground_impact_sprite.flip_h = velocity.x < 0.0
		dash_sprite.flip_h = dash_direction < 0.0
