class_name Character

extends CharacterBody2D

var direction:Vector2 = Vector2.ZERO

var is_run:bool = false

func _process(_delta):
    get_input_values()

func get_input_values():
    direction = Input.get_vector('left','right','backward','forward')
    is_run = Input.is_action_pressed('run')

func _physics_process(delta):
    movement()
    move_and_slide()

#region movement
@export_group("movement")
@export var walk_speed:float = 3.0

@export var run_speed:float = 6.0

func movement():
    velocity = direction * (walk_speed if !is_run else run_speed) * 40
#endregion
