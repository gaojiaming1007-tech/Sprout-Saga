class_name HoldItem

extends InventoryNode

var hold: Hold

func _enter_tree() -> void:
    current = GameManager.game.character.character_resource.hold.hold_inventory[int(name)]

func get_popup_position():
    var gp = get_global_mouse_position()
    return Vector2(gp.x + 10, gp.y - GameManager.game.inventory_info_popup.root.size.y)

func reset():
    %Back.visible = false

func set_current():
    %Back.visible = true

func on_left_click():
    super.on_left_click()
    hold.update_current_select(int(name))
