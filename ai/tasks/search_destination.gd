extends Action

@export var circle: int = 50

func _enter() -> void:
    super._enter()
    GameManager.game.current_level_instance.load_soild_cell()

func _tick(_delta: float) -> Status:
    var target_position = npc.global_position + Vector2(circle, circle) * Vector2(randf_range(-1, 1), randf_range(-1, 1))
    if GameManager.game.current_level_instance.get_current_tile_enable_to_move(target_position):
        npc.machine.blackboard.set_var("move", true)
        npc.machine.blackboard.set_var("destination", target_position)
        return SUCCESS
    else:
        return RUNNING
