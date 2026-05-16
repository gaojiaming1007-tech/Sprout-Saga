class_name Cow

extends NPC

func _enter_tree() -> void:
    super._enter_tree()
    machine.blackboard.set_var("petting", false)

func emit_character_petting():
    var character = GameManager.game.character
    if character.current_action_state == Character.ActionState.OneShot: return
    machine.blackboard.set_var("petting", true)
    await character.animation_state.start_one_shot(Character.OneShotState.Petting)
    machine.blackboard.set_var("petting", false)

func _on_character_entered(body: Node2D) -> void:
    if body is Character:
        machine.blackboard.set_var("is_range", true)
        machine.restart()
