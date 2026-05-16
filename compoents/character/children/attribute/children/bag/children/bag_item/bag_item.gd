class_name BagItem

extends InventoryNode

@export var bag: Bag

func _enter_tree() -> void:
    current = GameManager.game.character.character_resource.bag.bag_inventory[int(name)]
