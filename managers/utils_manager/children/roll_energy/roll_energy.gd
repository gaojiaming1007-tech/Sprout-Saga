class_name RollEnergy

extends Node2D

@export var energy: NinePatchRect

@export var line: Control

signal output(delta: float)

var current_value: float = 0.0

var best_value: float = 1.0

func _enter_tree() -> void:
    line.position.y = 27 * (1.0 - best_value)

func _process(delta: float) -> void:
    update_size()
    distribute_input()

func update_size():
    current_value = fmod(current_value + 28 * get_process_delta_time(), 27)
    energy.size.y = current_value
    energy.position.y = 27 - current_value

func distribute_input():
    if Input.is_action_just_pressed("roll_energy"):
        var percent = current_value / 27.0
        output.emit(abs(percent - best_value))
