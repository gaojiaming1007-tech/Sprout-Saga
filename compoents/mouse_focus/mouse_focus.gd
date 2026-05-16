class_name MouseFocus

extends Node2D

func _process(_delta):
    visible = !InterfaceNode.above && !GameManager.game.character.is_dialogue
    var mouse_position = get_global_mouse_position()
    global_position = UtilsManager.transform_position_tile(mouse_position)
