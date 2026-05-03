class_name Interact

extends Control

@onready var character: Character = get_parent()

enum KeyboardType {
    None = -1,
    Pickable,
    Fishing,
    FishingHooked
}

@export var keybaord_resource: InteractKeyboardResource

var current_keyboard_type: KeyboardType = KeyboardType.None

func _process(delta: float) -> void:
    update_visible()
    update_content()

func update_visible():
    if character.current_action_state == Character.ActionState.OneShot:
        visible = false
        current_keyboard_type = KeyboardType.None
        return
    if character.pickable_list.size() != 0:
        visible = true
        return
    if character.is_fishing:
        visible = true
        return
    visible = false

func update_content():
    if !visible:
        return
    if character.pickable_list.size() != 0:
        current_keyboard_type = KeyboardType.Pickable
    elif character.is_fishing:
        current_keyboard_type = KeyboardType.FishingHooked if character.is_hooked else KeyboardType.Fishing

    var resource = keybaord_resource.keyboard_list[current_keyboard_type]
    %Icon.texture = resource['keyboard']
    %Text.text = resource['label']
