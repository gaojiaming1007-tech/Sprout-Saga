class_name ShopItem

extends InventoryNode

func _get_drag_data(at_position: Vector2) -> Variant:
    return null

func _can_drop_data(_at_position: Vector2, target: ) -> bool:
    return false

func update_display():
    %Icon.texture = current["inventory"]["texture"]
    %Count.text = ""


func _on_buy_pressed() -> void:
    UtilsManager.start_quantity_selection(1, 99, 1,
        func(count: int):
            GameManager.game.character.to_buy_inventory(current['inventory'], count)
    )
