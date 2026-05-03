extends HoldEffectResource

func get_cell_limit(at_position: Vector2):
    if !GameManager.game.current_level_instance: return false
    return GameManager.game.current_level_instance.get_current_tile_can_axe(at_position)

func get_range():
    return 1

func has_oblique_angle():
    return false

func play_effect(at_position: Vector2):
    var character = GameManager.game.character
    character.update_face_direction(at_position)
    character.animation_state.start_one_shot(Character.OneShotState.Axe)
    await character.axe_target
    var fellable_tree: FellableTree = GameManager.game.current_level_instance.get_fellable_tree_from_position(at_position)
    if fellable_tree != null:
        fellable_tree.to_axe()
    else:
        print("查找不到FellableTree")
