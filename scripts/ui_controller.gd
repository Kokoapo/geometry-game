class_name UI_Controller
extends CanvasLayer

@onready var score_label: Label = $Control/MarginContainer/Label

func set_score(score: int) -> void:
	score_label.text = str(score)
