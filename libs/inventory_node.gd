class_name InventoryNode

extends InterfaceNode


var current: Dictionary

func _ready() -> void:
    update_display()

func update_display():
    pass

func on_mouse_enter():
    super.on_mouse_enter()
    if current.size() == 0:
        return
    GameManager.game.inventory_info_popup.set_current_inventory(self )
    GameManager.game.inventory_info_popup.show_popup()

func on_mouse_exit():
    super.on_mouse_exit()
    if current.size() == 0:
        return
    GameManager.game.inventory_info_popup.hide_popup()

func on_move():
    super.on_move()
    if current.size() == 0:
        return
    GameManager.game.inventory_info_popup.update_popup(get_popup_position())

func get_popup_position():
    return get_global_mouse_position() + Vector2(10, 0)

func _get_drag_data(at_position: Vector2) -> Variant:
    if current.size() == 0:
        return null
    else:
        set_drag_preview(create_preview(self , at_position))
        return {
            "type": "Inventory",
            "target": self
        }

func _can_drop_data(_at_position: Vector2, target: ) -> bool:
    return target.has("type") && target["type"] == "Inventory" && target["target"] != self

func _drop_data(at_position: Vector2, data) -> void:
    var target: InventoryNode = data["target"]
    exchange_inventory(self , target)

    GameManager.game.inventory_info_popup.set_current_inventory(self )

    GameManager.game.inventory_info_popup.show_popup()


static func exchange_inventory(i1: InventoryNode, i2: InventoryNode):
    var origin = i1.current
    var target = i2.current
    if origin.size() == 0:
        origin["inventory"] = target["inventory"]
        origin["count"] = target["count"]
        target.clear()
    else:
        var temp = {
            "inventory": origin["inventory"],
            "count": origin["count"],
        }
        origin["inventory"] = target["inventory"]
        origin["count"] = target["count"]
        target["inventory"] = temp["inventory"]
        target["count"] = temp["count"]
    i1.update_display()
    i2.update_display()

static func create_preview(target: InventoryNode, offset: Vector2):
    var container := Control.new()
    container.z_index = 1000
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var preview: InventoryNode = target.duplicate()
    preview.modulate.a = 0.5
    preview.position = - offset
    container.add_child(preview)
    return container