extends Node2D

@export var max_health := 100.0
@export var health_depletion_rate := 1.0

var health := max_health

@onready var health_bar: ProgressBar = get_node_or_null("HUD/HealthBar")
@onready var player: CharacterBody2D = $TestPlayer

func _ready() -> void:
	player.hard_landed.connect(_on_player_hard_landed)
	player.dash_started.connect(_on_player_dash_started)
	if health_bar == null:
		var hud := CanvasLayer.new()
		hud.name = "HUD"
		hud.layer = 10
		add_child(hud)
		health_bar = ProgressBar.new()
		health_bar.name = "HealthBar"
		health_bar.position = Vector2(12, 12)
		health_bar.size = Vector2(100, 10)
		health_bar.show_percentage = true
		hud.add_child(health_bar)
	health_bar.max_value = max_health
	health_bar.value = health
	queue_redraw()

func _on_player_hard_landed() -> void:
	health = maxf(health - 4.0, 0.0)
	health_bar.value = health

func _on_player_dash_started() -> void:
	health = maxf(health - 3.0, 0.0)
	health_bar.value = health

func _process(delta: float) -> void:
	health = maxf(health - health_depletion_rate * delta, 0.0)
	health_bar.value = health
	if is_zero_approx(health):
		get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")

func _draw() -> void:
	draw_rect(Rect2(0, 0, 3200, 720), Color("#18252d"))
	draw_rect(Rect2(0, 430, 3200, 290), Color("#203b3d"))

	for x in range(0, 3201, 160):
		draw_line(Vector2(x, 0), Vector2(x, 720), Color(1, 1, 1, 0.035), 1.0)
	for y in range(80, 721, 80):
		draw_line(Vector2(0, y), Vector2(3200, y), Color(1, 1, 1, 0.035), 1.0)

	draw_string(ThemeDB.fallback_font, Vector2(48, 64), "CAMERA FLOW TEST", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f1c75b"))
	draw_string(ThemeDB.fallback_font, Vector2(48, 94), "A/D: move    W / Space: jump    S: fast fall", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b7c8c3"))
	draw_string(ThemeDB.fallback_font, Vector2(1300, 340), "FOLLOW ZONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.28))
