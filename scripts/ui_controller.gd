class_name UI_Controller
extends CanvasLayer

@onready var score_label: Label = $Control/MarginContainer/Label
@onready var game_over_screen: VBoxContainer = $Control/MarginContainer/VBoxContainer

func set_score(score: int) -> void:
	score_label.text = str(score)

func set_game_over_screen(is_enabled: bool) -> void: 
	game_over_screen.visible = is_enabled
	
