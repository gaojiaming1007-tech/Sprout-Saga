class_name BuildingHoldEffectResourceBase

extends HoldEffectResource

func get_cell_limit(at_position: Vector2):
    if !GameManager.game.current_level_instance: return false
    return GameManager.game.current_level_instance.get_current_tile_can_building(at_position)

func get_range():
    return 2

func has_oblique_angle():
    return false

func play_effect(at_position: Vector2):
    var character = GameManager.game.character
    await character.animation_state.start_one_shot(Character.OneShotState.Collect)
    GameManager.game.current_level_instance.add_building(at_position, character.attribute.hold.hold_item_list[character.attribute.hold.current_select])
