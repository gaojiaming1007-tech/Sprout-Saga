class_name InventoryPreview

extends CanvasLayer

@export var inventory_node: InventoryNode

var center: Vector2

func _process(_delta: float) -> void:
    inventory_node.position = inventory_node.get_global_mouse_position() - center
    if Input.is_action_just_released("left_mouse"):
        queue_free()
