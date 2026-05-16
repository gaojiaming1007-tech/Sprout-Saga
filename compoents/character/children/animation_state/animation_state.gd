class_name AnimationState

extends Node2D

@onready var character: Character = get_parent()

func _ready() -> void:
    character.animation_tree.animation_finished.connect(on_animation_finished)

func _physics_process(_delta):
    set_animation_tree_state()

func has_accelerate():
    return character.current_action_state == Character.ActionState.Default || character.current_action_state == Character.ActionState.Lift || character.current_action_state == Character.ActionState.Steed

func set_animation_tree_state():
    if character.current_action_state == Character.ActionState.OneShot:
        return
    else:
        set_loop()

func set_loop():
    character.animation_tree.set("parameters/movement_state/blend_position", character.current_action_state)
    if has_accelerate():
        if character.current_action_state == Character.ActionState.Steed:
            character.animation_tree.set("parameters/movement_state/%s/%s/blend_position" % [character.current_action_state, character.ACTION_STATE[character.current_action_state]], character.character_resource.current_steed_type)
            character.animation_tree.set("parameters/movement_state/%s/%s/%s/%s/blend_amount" % [character.current_action_state, character.ACTION_STATE[character.current_action_state], character.character_resource.current_steed_type, Character.STEED_TYPE[character.character_resource.current_steed_type]], character.current_movement_state)
            character.animation_tree.set("parameters/movement_state/%s/%s/%s/%s/blend_amount" % [character.current_action_state, character.ACTION_STATE[character.current_action_state], character.character_resource.current_steed_type, Character.MOVEMENT_STATE[character.current_movement_state]], character.current_face_direction)
        else:
            character.animation_tree.set("parameters/movement_state/%s/%s/blend_amount" % [character.current_action_state, character.ACTION_STATE[character.current_action_state]], character.current_movement_state)
            character.animation_tree.set("parameters/movement_state/%s/%s/blend_amount" % [character.current_action_state, character.MOVEMENT_STATE[character.current_movement_state]], character.current_face_direction)
    else:
        character.animation_tree.set("parameters/movement_state/%s/%s/blend_amount" % [character.current_action_state, Character.ACTION_STATE[character.current_action_state]], character.current_face_direction)

func start_one_shot(state: Character.OneShotState):
    character.current_action_state = Character.ActionState.OneShot
    character.animation_tree.set("parameters/one_shot_state/blend_position", state)
    character.animation_tree.set("parameters/one_shot_state/%s/%s/blend_amount" % [state, Character.ONESHOT_STATE[state]], character.current_face_direction)
    character.animation_tree.set("parameters/one_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    await character.animation_tree.animation_finished

func on_animation_finished(e: String):
     character.current_action_state = Character.ActionState.Default