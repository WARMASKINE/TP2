extends Node2D

func _ready() -> void:
	queue_redraw()

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
