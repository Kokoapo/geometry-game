extends Node2D

@onready var timer: Timer = $Timer
@onready var ui_controller: UI_Controller = $CanvasLayer

@export var shape_scenes: Array[PackedScene] = []
@export var y_limit: int = 0
@export var inf_limit: int = 0
@export var sup_limit: int = 0

var shape_holding: Shape
var score: int

func _ready() -> void:
	hold_shape()
	score = 0
	ui_controller.set_score(score)
	
func _process(_delta: float) -> void:
	if shape_holding:
		shape_holding.global_position.x = clampf(get_global_mouse_position().x, inf_limit, sup_limit)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_shape") and shape_holding:
		shape_holding.gravity_scale = 1.0
		shape_holding = null
		timer.start()

func get_random_shape_scene() -> PackedScene:
	var index: int = randi_range(0, shape_scenes.size()-1)
	return shape_scenes[index]

func hold_shape() -> void:
	var shape_scene: PackedScene = get_random_shape_scene()
	var shape_instance: Shape = create_shape(shape_scene, Vector2(get_global_mouse_position().x, y_limit))
	shape_instance.gravity_scale = 0.0
	shape_holding = shape_instance

func create_shape(shape_scene: PackedScene, pos: Vector2) -> Shape:
	var shape_instance: Shape = shape_scene.instantiate()
	
	shape_instance.global_position = pos
	call_deferred("add_child", shape_instance)
	shape_instance.merge.connect(_on_merge)

	return shape_instance

func _on_timer_timeout() -> void:
	hold_shape()
	
func _on_merge(level: int, shape_1: Shape, shape_2: Shape) -> void:
	var pos: Vector2 = floor((shape_1.global_position + shape_2.global_position) / 2)
	shape_1.queue_free()
	shape_2.queue_free()
	
	if level < shape_scenes.size():
		var shape_scene: PackedScene = shape_scenes[level]
		var _shape_instance: Shape = create_shape(shape_scene, pos)
	
	score += 2**level
	ui_controller.set_score(score)
	
