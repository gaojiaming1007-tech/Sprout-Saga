class_name Shop

extends CanvasLayer

var shop_resource: ShopResource

var tween: Tween

@export var root: PanelContainer

signal finish

func _enter_tree() -> void:
    visible = false
    load_items()

func load_items():
    %List.columns = shop_resource.columns
    for i in range(shop_resource.inventory_list.size()):
        var item: ShopItem = ResourceManager.load_resource("res://managers/utils_manager/children/shop/children/shop_item/shop_item.tscn").instantiate()
        item.current = {
            "inventory": shop_resource.inventory_list[i],
            "count": 1
        }
        %List.add_child(item)

func _ready() -> void:
    var r_size = UtilsManager.get_render_size()
    root.position = Vector2(r_size.x, 50)
    visible = true
    tween = create_tween()
    tween.tween_property(root, "position:x", r_size.x - root.size.x - 20, 0.1)

func close():
    var r_size = UtilsManager.get_render_size()
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(root, "position:x", r_size.x, 0.1)
    await tween.finished
    finish.emit()


func _on_close_pressed() -> void:
    close()
