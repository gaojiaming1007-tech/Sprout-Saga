class_name RangePrompt

extends Node2D

var is_enter: bool = false

var last_count: int = -1

@export var area: Area2D

@export var shape: CollisionShape2D

@export var color_rect: ColorRect

var last_position: Vector2i = Vector2i(0, 0)

var range_result: Array[bool]

func _enter_tree() -> void:
    GameManager.game.level_loaded.connect(
        func():
            update_position(true)
    )

func _process(delta):
    update_visible()
    distribute_input()
    update_position()

func update_visible():
    var character = GameManager.game.character

    if character.is_dialogue:
        visible = false
        return

    if character.current_action_state == Character.ActionState.OneShot:
        visible = false
        return
    if !character.attribute.hold.current_effect:
        visible = false
        return
    if character.is_fishing:
        visible = false
        return
    if character.character_resource.current_steed_type != Character.SteedType.None:
        visible = false
        return
    
    visible = true

func distribute_input():
    if Input.is_action_just_pressed("left_mouse") && !InterfaceNode.above && visible && is_enter:
        on_left_click()

func on_left_click():
    var character = GameManager.game.character
    if character.is_interfact_state():
        deal_hold_action()

func deal_hold_action():
    var character = GameManager.game.character
    var result = color_rect.get_local_mouse_position()
    var grid = Vector2i(floor(result.x / 16), floor(result.y / 16))
    var place = range_result[grid.y * (last_count * 2 + 1) + grid.x]
    if place:
        character.attribute.hold.current_effect.play_effect(get_global_mouse_position())
    else:
        print("不在可交互范围")

func _on_area_2d_mouse_entered() -> void:
    is_enter = true

func _on_area_2d_mouse_exited() -> void:
    is_enter = false

func show_range(range_count: int):
    last_count = range_count
    var count = range_count * 2 + 1
    color_rect.material.set("shader_parameter/grid_x", count)
    color_rect.material.set("shader_parameter/grid_y", count)
    visible = true
    (shape.shape as RectangleShape2D).size = Vector2(count * 16, count * 16)
    color_rect.size = Vector2(count * 16, count * 16)
    area.position = Vector2(count * 8, count * 8)
    update_position(true)

func set_shader_texture():
    var character = GameManager.game.character
    var limit = character.attribute.hold.current_effect.update_texture_limit()
    range_result = limit[0]
    color_rect.material.set("shader_parameter/color_texture", limit[1])

func update_position(force = false):
    if !visible:
        return
    var character = GameManager.game.character

    var p: Vector2i = UtilsManager.transform_position_tile(character.global_position)

    if p != last_position || force:
        last_position = p
        set_shader_texture()
        global_position = Vector2(p.x - last_count * 16, p.y - last_count * 16)
