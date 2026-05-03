class_name GlobalLight

extends Node2D

@export var light: PointLight2D

var current_energy: float = 1.0

@export var curve: Curve

func _ready() -> void:
    GameManager.game.time_record.time_update.connect(on_time_update)
    on_time_update()

func on_time_update():
    if GameManager.game.current_level_instance:
            var resource = GameManager.game.game_resource
            var current_hour = float(resource.hour) + (float(resource.minute) / 60.0)
            var cosine_value = cos((current_hour / 12) * PI)
            ## [-1,1] -> [0,1]
            var normailzed = (cosine_value + 1) / 2
            current_energy = curve.sample(normailzed)
        
    else:
        current_energy = 1

func _process(delta):
    light.energy = move_toward(light.energy, current_energy, delta * 2)

func _physics_process(delta: float) -> void:
    global_position = GameManager.game.character.global_position
