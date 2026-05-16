extends Action

@export var contrary: bool = false

func _enter() -> void:
    super._enter()

    var p1 = GameManager.game.character.global_position
    var p2 = npc.global_position

    var face_direction = UtilsManager.get_direction_from_position(p1, p2)
    blackboard.set_var("face_direction", face_direction)
    
    if face_direction == Character.FaceDirection.Parallel:
        if !contrary:
            npc.graphics.scale.x = 1.0 if p1.x > p2.x else -1.0
        else:
            npc.graphics.scale.x = -1.0 if p1.x > p2.x else 1.0
