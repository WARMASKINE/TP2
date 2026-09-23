extends Control

@onready var start_game_button: BaseButton = $StartGameButton

func _ready() -> void:
	start_game_button.pressed.connect(_on_start_game_pressed)
	start_game_button.grab_focus()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_test.tscn")
