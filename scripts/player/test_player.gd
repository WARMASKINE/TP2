extends CharacterBody2D

@export var move_speed := 260.0
@export var acceleration := 1800.0
@export var jump_velocity := -560.0
@export var gravity := 1500.0

var wasd_jump_pressed := false

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
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 22.0, Color("#f1c75b"))
	draw_circle(Vector2(-8.0, -4.0), 4.0, Color("#20262b"))
	draw_circle(Vector2(8.0, -4.0), 4.0, Color("#20262b"))
	draw_arc(Vector2.ZERO, 14.0, 0.35, 2.8, 20, Color("#20262b"), 2.0)
	draw_line(Vector2(-16.0, 18.0), Vector2(-22.0, 26.0), Color("#20262b"), 4.0)
	draw_line(Vector2(16.0, 18.0), Vector2(22.0, 26.0), Color("#20262b"), 4.0)
