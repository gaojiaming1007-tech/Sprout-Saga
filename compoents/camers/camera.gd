class_name Camera

extends Node2D

@export var camera2d: Camera2D

@export var phantom_camera2D: PhantomCamera2D

@export var camera_emitter: PhantomCameraNoiseEmitter2D

func set_limit():
    var bound = GameManager.game.current_level_instance.get_bound()
    phantom_camera2D.limit_left = bound.position.x + 16
    phantom_camera2D.limit_top = bound.position.y + 16
    phantom_camera2D.limit_right = bound.end.x - 16
    phantom_camera2D.limit_bottom = bound.end.y - 16
    print(bound)

func set_follow_target(target: Character):
    if !phantom_camera2D.follow_target:
        phantom_camera2D.set_follow_target(target)


    phantom_camera2D.teleport_position()

func shake(amplitude: float = 10.0, frequency: float = 4.0, duration: float = 0.1):
    print("shake")
    camera_emitter.noise.amplitude = amplitude
    camera_emitter.noise.frequency = frequency
    camera_emitter.duration = duration
    camera_emitter.emit()
