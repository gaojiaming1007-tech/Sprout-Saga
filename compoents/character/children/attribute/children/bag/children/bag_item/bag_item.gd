class_name BagItem

extends InventoryNode

@export var icon: TextureRect

@export var count: Label

@export var bag: Bag

func _enter_tree() -> void:
    current = GameManager.game.character.character_resource.bag.bag_inventory[int(name)]

func update_display():
    if current.size() != 0:
        icon.texture = current["inventory"]["texture"]
        count.text = str(current["count"] if current["inventory"]["stack"] else "")
    else:
        icon.texture = null
        count.text = ""
