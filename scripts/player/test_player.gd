extends CharacterBody2D

const IDLE_FRAME_COUNT := 16
const WALK_FRAME_COUNT := 12
const AIR_FRAME_COUNT := 12

@export var move_speed := 260.0
@export var acceleration := 1800.0
@export var jump_velocity := -560.0
@export var gravity := 1500.0

var wasd_jump_pressed := false
var animation_time := 0.0

@onready var raccoon_sprite: Sprite2D = $RaccoonSprite
@onready var walking_sprite: Sprite2D = $WalkingSprite
@onready var air_sprite: Sprite2D = $AirSprite

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_physical_key_pressed(KEY_S):
			velocity.y += gravity * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_physical_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction += 1.0
	direction = clampf(direction, -1.0, 1.0)
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)

	var wasd_jump_just_pressed := Input.is_physical_key_pressed(KEY_W) and not wasd_jump_pressed
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or wasd_jump_just_pressed:
		if is_on_floor():
			velocity.y = jump_velocity
	wasd_jump_pressed = Input.is_physical_key_pressed(KEY_W)

	move_and_slide()
	_update_animation(delta)

func _update_animation(delta: float) -> void:
	animation_time += delta
	var is_grounded := is_on_floor()
	var is_walking := is_grounded and absf(velocity.x) > 10.0
	var is_idle := is_grounded and not is_walking
	var is_airborne := not is_grounded
	var was_idle := raccoon_sprite.visible
	if is_idle and not was_idle:
		animation_time = 0.0
	raccoon_sprite.visible = is_idle
	walking_sprite.visible = is_walking
	air_sprite.visible = is_airborne
	if is_idle:
		raccoon_sprite.frame = int(animation_time * 8.0) % IDLE_FRAME_COUNT
	if is_walking:
		walking_sprite.frame = int(animation_time * 10.0) % WALK_FRAME_COUNT
	if is_airborne:
		air_sprite.frame = int(animation_time * 10.0) % AIR_FRAME_COUNT

	if absf(velocity.x) > 10.0:
		raccoon_sprite.flip_h = velocity.x < 0.0
		walking_sprite.flip_h = velocity.x < 0.0
		air_sprite.flip_h = velocity.x < 0.0
