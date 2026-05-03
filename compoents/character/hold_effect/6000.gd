extends HoldEffectResource

func get_cell_limit(at_position: Vector2):
    if !GameManager.game.current_level_instance: return false
    return GameManager.game.current_level_instance.get_current_has_farmland(at_position)

func get_range():
    return 1

func has_oblique_angle():
    return false

func play_effect(at_position: Vector2):
    var character = GameManager.game.character
    character.update_face_direction(at_position)
    character.animation_state.start_one_shot(Character.OneShotState.Watering)
    await character.watering_target
    var farmland: Farmland = GameManager.game.current_level_instance.get_farmland_from_position(at_position)
    if farmland != null:
        farmland.to_watering()
    else:
        print("查找不到Farmland")
