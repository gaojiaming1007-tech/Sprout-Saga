class_name HoldItem

extends InventoryNode

@export var icon: TextureRect

@export var count: Label

@export var back: NinePatchRect

var hold: Hold

func _enter_tree() -> void:
    current = GameManager.game.character.character_resource.hold.hold_inventory[int(name)]

func update_display():
    if current.size() != 0:
        icon.texture = current["inventory"]["texture"]
        count.text = str(current["count"] if current["inventory"]["stack"] else "")
    else:
        icon.texture = null
        count.text = ""

func get_popup_position():
    var gp = get_global_mouse_position()
    return Vector2(gp.x + 10, gp.y - GameManager.game.inventory_info_popup.root.size.y)

func reset():
    back.visible = false

func set_current():
    back.visible = true

func on_left_click():
    super.on_left_click()
    hold.update_current_select(int(name))
