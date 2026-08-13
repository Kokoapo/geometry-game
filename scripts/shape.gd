class_name Shape
extends RigidBody2D

@onready var area2d: Area2D = $Area2D

@export var level: int

signal merge

func _ready() -> void:
	area2d.area_entered.connect(_on_area2d_entered)
	
func _on_area2d_entered(area: Area2D) -> void:
	if (area.get_parent().is_class("RigidBody2D")):
		var shape: Shape = area.get_parent()
		if shape.level == level:
			merge.emit(level+1, self, shape)
