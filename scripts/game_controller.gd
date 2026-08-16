extends Node2D

@onready var timer: Timer = $Timer
@onready var ui_controller: UI_Controller = $CanvasLayer

@export var shape_scenes: Array[PackedScene] = []
@export var y_limit: int = 0
@export var inf_limit: int = 0
@export var sup_limit: int = 0
@export var level_up: int = 0
@export var y_game_over: int = 0

var shape_holding: Shape = null
var score: int = 0
var current_round: int = 0
var spawned_shapes: Array[Shape] = []
var is_running: bool = true

func _ready() -> void:
	reset_game()
	
func _process(_delta: float) -> void:
	if shape_holding and is_running:
		shape_holding.global_position.x = clampf(get_global_mouse_position().x, inf_limit, sup_limit)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_shape") and shape_holding and is_running:
		shape_holding.gravity_scale = 1.0
		shape_holding = null
		timer.start()
		
func _on_timer_timeout() -> void:
	for shape in spawned_shapes:
		if shape.position.y <= y_game_over:
			game_over()
	
	hold_shape()
	current_round += 1
	
func _on_merge(level: int, shape_1: Shape, shape_2: Shape) -> void:
	var pos: Vector2 = floor((shape_1.global_position + shape_2.global_position) / 2)
	
	delete_shape(shape_1)
	delete_shape(shape_2)
	
	if level < shape_scenes.size():
		var shape_scene: PackedScene = shape_scenes[level]
		var _shape_instance: Shape = create_shape(shape_scene, pos)
	
	score += 2**level
	ui_controller.set_score(score)
	
func _on_button_pressed() -> void:
	ui_controller.set_game_over_screen(false)
	reset_game()
	is_running = true

func get_random_shape_scene() -> PackedScene:
	var limit: int = current_round / level_up
	if limit >= shape_scenes.size():
		limit = shape_scenes.size() - 1
	var index: int = randi_range(0, limit)
	return shape_scenes[index]

func hold_shape() -> void:
	var shape_scene: PackedScene = get_random_shape_scene()
	var shape_instance: Shape = create_shape(shape_scene, Vector2(clampf(get_global_mouse_position().x, inf_limit, sup_limit), y_limit))
	shape_instance.gravity_scale = 0.0
	shape_holding = shape_instance

func create_shape(shape_scene: PackedScene, pos: Vector2) -> Shape:
	var shape_instance: Shape = shape_scene.instantiate()
	
	shape_instance.global_position = pos
	shape_instance.rotate(randi())
	
	call_deferred("add_child", shape_instance)
	shape_instance.merge.connect(_on_merge)
	
	spawned_shapes.append(shape_instance)

	return shape_instance
	
func delete_shape(shape: Shape) -> void:
	spawned_shapes.erase(shape)
	shape.queue_free()
	
func game_over() -> void:
	is_running = false
	ui_controller.set_game_over_screen(true)
	
func reset_game() -> void:
	if shape_holding:
		delete_shape(shape_holding)
		shape_holding = null
	
	for shape in spawned_shapes:
		shape.queue_free()
	spawned_shapes.clear()
	
	hold_shape()
	score = 0
	ui_controller.set_score(score)
