class_name Hold

extends InterfaceNode

var hold_item_list: Array[HoldItem] = []

var current_select: int = -1

var current_effect: HoldEffectResource

func _enter_tree() -> void:
    for child in %ListContainer.get_children():
        if child is HoldItem:
            child.hold = self
            hold_item_list.append(child)

func _ready() -> void:
    update_current_select(GameManager.game.character.character_resource.current_hold_select)

func update_current_select(index: int):
    current_select = index
    for i in hold_item_list:
        if int(i.name) == current_select:
            i.set_current()
        else:
            i.reset()
    update_lift()
    update_effect()

func update_lift():
    var character = GameManager.game.character
    var inventory = get_current_select()
    if inventory && inventory["lift"]:
        var t_size: Vector2 = inventory["highlight_texture"].get_size()
        character.lift_sprite.texture = inventory["highlight_texture"]
        character.lift_sprite.offset = Vector2(0, -t_size.y / 2)
        character.lift_sprite.scale = Vector2.ONE * (12.0 / float(t_size.y))
    else:
        character.lift_sprite.texture = null

func update_effect():
    var inventory = get_current_select()
    var resource: Resource = ResourceManager.load_resource("res://compoents/character/hold_effect/%s.gd" % [inventory["id"] if inventory != null else -1])
    if !resource:
        current_effect = null
    else:
        current_effect = resource.new()
        GameManager.game.range_prompt.show_range(current_effect.get_range())

func get_current_select():
    var current: Dictionary = hold_item_list[current_select].current
    if current.size() != 0:
        return current["inventory"]
    else:
        return null
