class_name SeedHoldEffectResourceBase

extends HoldEffectResource

func get_cell_limit(at_position: Vector2):
    if !GameManager.game.current_level_instance: return false
    return GameManager.game.current_level_instance.get_current_tile_can_sow(at_position)

func get_range():
    return 1

func has_oblique_angle():
    return false

func play_effect(at_position: Vector2):
    var character = GameManager.game.character
    character.update_face_direction(at_position)
    await character.animation_state.start_one_shot(Character.OneShotState.Collect)
    var farmland: Farmland = GameManager.game.current_level_instance.get_farmland_from_position(at_position)
    if farmland != null:
        farmland.to_saw(character.attribute.hold.hold_item_list[character.attribute.hold.current_select])
    else:
        print("查找不到Farmland")
