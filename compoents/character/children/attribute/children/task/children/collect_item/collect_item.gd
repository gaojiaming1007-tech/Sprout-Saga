class_name CollectItem

extends InventoryNode

func _get_drag_data(at_position: Vector2) -> Variant:
    return null

func _can_drop_data(_at_position: Vector2, target: ) -> bool:
    return false

func update_display():
    %Icon.texture = current["inventory"]["texture"]
    %Count.text = "%s/%s" % [current['has'], current['count']]
