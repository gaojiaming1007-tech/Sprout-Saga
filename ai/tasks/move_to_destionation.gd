extends Action

var points

var target_position: Vector2

@export var contrary: bool = false

@export var move_speed: float = 20.0

func _enter() -> void:
    super._enter()
    points = GameManager.game.current_level_instance.get_astar_path_to(npc.global_position, blackboard.get_var("destination"))

func _tick(delta: float) -> Status:
    if points.is_empty():
        blackboard.set_var('move', false)
        npc.move_finish.emit()
        return SUCCESS
    target_position = points[0]
    set_face_direction()
    play_animation()
    npc.global_position = npc.global_position.move_toward(target_position, move_speed * delta)
    if npc.global_position == target_position:
        points.remove_at(0)
    return RUNNING

func set_face_direction():
    var p1 = target_position
    var p2 = npc.global_position
    var face_direction = UtilsManager.get_direction_from_position(p1, p2)
    blackboard.set_var("face_direction", face_direction)
    if face_direction == Character.FaceDirection.Parallel:
        if !contrary:
            npc.graphics.scale.x = 1.0 if p1.x > p2.x else -1.0
        else:
            npc.graphics.scale.x = -1.0 if p1.x > p2.x else 1.0

func play_animation():
    var current = "walk_%s" % [Character.FACE_DIRECTION[blackboard.get_var("face_direction")]]
    if npc.animation_sprite2d.animation != current || !npc.animation_sprite2d.is_playing():
        npc.animation_sprite2d.play(current)
