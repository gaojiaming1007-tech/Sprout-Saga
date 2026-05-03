class_name Camera

extends Node2D

@export var camera2d:Camera2D

@export var phantom_camera2D: PhantomCamera2D

func set_limit():
    var bound = GameManager.game.current_level_instance.get_bound()
    phantom_camera2D.limit_left = bound.position.x
    phantom_camera2D.limit_top = bound.position.y
    phantom_camera2D.limit_right = bound.end.x
    phantom_camera2D.limit_bottom = bound.end.y

func set_follow_target(target:Character):
    if !phantom_camera2D.follow_target:
        phantom_camera2D.set_follow_target(target)


    phantom_camera2D.teleport_position()
