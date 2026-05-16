class_name SellingArea

extends InterfaceNode

func _can_drop_data(_at_position: Vector2, target: ) -> bool:
    return target.has("type") && target["type"] == "Inventory" && target["target"] != self

func _drop_data(at_position: Vector2, data) -> void:
   var target: InventoryNode = data['target']
   UtilsManager.start_quantity_selection(1, target.current["count"], 1,
        func(count: int):
            GameManager.game.character.selling_inventory(target, count)
   )
