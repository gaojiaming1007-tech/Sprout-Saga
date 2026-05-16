class_name SteedNPC

extends NPC

func _on_character_entered(body: Node2D) -> void:
    if body is Character:
        machine.blackboard.set_var("is_range", true)
        machine.restart()

func emit_character_steed():
    var character = GameManager.game.character
    character.switch_steed(self )
