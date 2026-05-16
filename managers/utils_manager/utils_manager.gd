extends Node

class ScreenPostionResult:
    var position: Vector2
    var canvas_position: Vector2
    var is_on_screen: bool

    func _init(_positon: Vector2, _canvas_position: Vector2, _is_on_screen: bool):
        self.position = _positon
        self.canvas_position = _canvas_position
        self.is_on_screen = _is_on_screen

func get_screen_position(node: Node2D) -> ScreenPostionResult:
    var viewport := get_viewport()
    var canvas_position := viewport.canvas_transform * node.global_position
    var viewport_size := viewport.get_visible_rect().size

    var normalized := Vector2(canvas_position.x / viewport_size.x, canvas_position.y / viewport_size.y)

    return ScreenPostionResult.new(normalized, canvas_position, (normalized.x > 0.0 && normalized.x <= 1.0 && normalized.y > 0.0 && normalized.x <= 1.0))

func get_render_size() -> Vector2:
    return get_viewport().get_visible_rect().size

func transform_position_tile(at_positon: Vector2) -> Vector2i:
    return Vector2i(floor(at_positon.x / 16) * 16, floor(at_positon.y / 16) * 16)

func get_direction_from_position(at_position: Vector2, target_postion: Vector2):
    var a_to_b: Vector2 = (target_postion - at_position).normalized()

    var a_forward: Vector2 = Vector2(0, 1)

    var angle_rad: float = a_to_b.angle_to(a_forward)

    if abs(angle_rad) < PI / 8: # 22.5度阈值
        return Character.FaceDirection.Backward
    elif abs(angle_rad) > 7 * PI / 8: # 157.5度阈值
        return Character.FaceDirection.Forward
    else:
        return Character.FaceDirection.Parallel

func drop_pickable(inventory: Inventory, count: int, at_position: Vector2):
    if inventory.stack:
        var drop: Pickable = ResourceManager.load_resource("res://compoents/pickable/pickable.tscn").instantiate()
        drop.inventory = inventory
        drop.count = count
        drop.global_position = at_position
        GameManager.game.current_level_instance.add_child(drop)
    else:
        for i in range(count):
            var drop: Pickable = ResourceManager.load_resource("res://compoents/pickable/pickable.tscn").instantiate()
            drop.inventory = inventory
            drop.count = 1
            drop.global_position = at_position
            GameManager.game.current_level_instance.add_child(drop)

var is_roll_energy: bool = false

func start_roll_energy(callback: Callable, at_parent: Node2D, best_value: float = 1.0):
    is_roll_energy = true
    var roll_energy: RollEnergy = ResourceManager.load_resource("res://managers/utils_manager/children/roll_energy/roll_energy.tscn").instantiate()
    roll_energy.best_value = best_value
    at_parent.add_child(roll_energy)
    roll_energy.output.connect(callback)
    await roll_energy.output
    roll_energy.queue_free()
    is_roll_energy = false

var is_shop: bool = false

func start_shop(shop_resource: ShopResource):
    is_shop = true
    var shop: Shop = ResourceManager.load_resource("res://managers/utils_manager/children/shop/shop.tscn").instantiate()
    shop.shop_resource = shop_resource
    add_child(shop)
    await shop.finish
    shop.queue_free()
    is_shop = false

var is_quantity_selection = false

func start_quantity_selection(min_value: int, max_value: int, value: int, callback: Callable):
    is_quantity_selection = true
    var quantity_selection: QuantitySelection = ResourceManager.load_resource("res://managers/utils_manager/children/quantity_selection/quantity_selection.tscn").instantiate()
    quantity_selection.set_default(min_value, max_value, value)
    add_child(quantity_selection)
    quantity_selection.finish.connect(callback)
    await quantity_selection.finish
    quantity_selection.queue_free()
    is_quantity_selection = false
