extends HoldEffectResource

func get_cell_limit(at_position: Vector2):
    if !GameManager.game.current_level_instance: return false
    return GameManager.game.current_level_instance.get_current_tile_can_hoe(at_position)

func get_range():
    return 2

func has_oblique_angle():
    return false

func play_effect(at_position: Vector2):
    var character = GameManager.game.character
    var hoe_position = UtilsManager.transform_position_tile(at_position)
    character.update_face_direction(at_position)
    character.animation_state.start_one_shot(Character.OneShotState.Hoe)
    await character.hoe_target
    ParticleManager.spawn_particle(ParticleManager.ParticleType.Hoe, UtilsManager.transform_position_tile(at_position) + Vector2i(8, 8))
    GameManager.game.current_level_instance.add_farmland(hoe_position)
