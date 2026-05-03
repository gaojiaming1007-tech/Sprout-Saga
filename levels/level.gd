class_name Level

extends Node2D

@export var level_resource: LevelResource

@export var farmland_layer: TileMapLayer

var farmlands: Array[Farmland]

var fellable_trees: Array[FellableTree]

func _ready() -> void:
    GameManager.quit.connect(save)
    load_exist_farmland()
    load_exist_fellable_tree()

func save():
    level_resource.last_position = GameManager.game.character.global_position
    ResourceManager.save_resource(level_resource)

func get_all_tile_map_layers():
    return find_child("TileMapLayerContianer", false, false).get_children()

func get_bound():
    var min_x = INF
    var min_y = INF
    var max_x = - INF
    var max_y = - INF

    for layer in get_all_tile_map_layers():
        if !layer.has_meta("bound_exclude"):
            var tile: TileMapLayer = layer
            var map_rect: Rect2i = tile.get_used_rect()
            var tile_size: Vector2i = tile.tile_set.tile_size
            var world_size := map_rect.size * tile_size
            var world_position := map_rect.position * tile_size
            min_x = min(min_x, world_position.x)
            min_y = min(min_y, world_position.y)
            max_x = max(max_x, world_position.x + world_size.x)
            max_y = max(max_y, world_position.y + world_size.y)
        
    return Rect2i(min_x, min_y, max_x - min_x, max_y - min_y)

func set_character_postion():
    GameManager.game.character.global_position = level_resource.last_position if !level_resource.last_position.is_zero_approx() else $OriginPoint.global_position

#region hold_effect_resource
## 当前位置是否可以种田
func get_current_tile_can_hoe(at_position: Vector2):
    for tile in get_all_tile_map_layers():
        var current_tile: TileMapLayer = tile
        var cell = current_tile.local_to_map(current_tile.to_local(at_position))
        if current_tile.get_cell_source_id(cell) != -1:
            var data = current_tile.get_cell_tile_data(cell)
            if data:
                if data.has_custom_data("farmland") && data.get_custom_data("farmland") && !get_current_has_farmland(at_position) && !get_current_has_farmland(at_position) && !get_current_tile_can_axe(at_position):
                    return true
    return false

func get_current_has_farmland(at_position):
    if !level_resource.farmland_exist_esource: return false
    var current_cell: Vector2i = farmland_layer.local_to_map(farmland_layer.to_local(at_position))
    for land in level_resource.farmland_exist_esource.lands:
        if current_cell == land["cell"]:
            return true
    return false

func get_current_tile_can_sickle(at_position: Vector2):
    if !level_resource.farmland_exist_esource: return false
    var current_cell: Vector2i = farmland_layer.local_to_map(farmland_layer.to_local(at_position))
    for land in level_resource.farmland_exist_esource.lands:
        if current_cell == land["cell"] && land["inventory"]:
            return true
    return false

func get_current_tile_can_axe(at_position: Vector2):
    if !level_resource.fellable_tree_exist_resource: return false
    var vi = UtilsManager.transform_position_tile(at_position)
    for fellable_tree in level_resource.fellable_tree_exist_resource.trees:
        if vi == fellable_tree["position"]:
            return true
    return false

func get_current_tile_can_sow(at_position: Vector2):
    if !level_resource.farmland_exist_esource: return true
    var current_cell: Vector2i = farmland_layer.local_to_map(farmland_layer.to_local(at_position))
    for land in level_resource.farmland_exist_esource.lands:
        if current_cell == land["cell"] && !land["inventory"]:
            return true
    return false

func get_current_tile_can_fishing(at_position: Vector2):
    var fish := false

    for tile in get_all_tile_map_layers():
        var current_tile: TileMapLayer = tile
        var cell = current_tile.local_to_map(current_tile.to_local(at_position))
        if current_tile.get_cell_source_id(cell) != -1:
            var data = current_tile.get_cell_tile_data(cell)
            if data:
                if data.has_custom_data('fish') && !data.get_custom_data('fish'):
                    return false
                else:
                    fish = true
    return fish

#endregion

#region farmland

func add_farmland(at_position: Vector2i):
    var cell := farmland_layer.local_to_map(farmland_layer.to_local(at_position))

    var land: Dictionary = {
        "inventory": null,
        "moisture": 0.2,
        "growth_time": 0,
        "cell": cell,
        "position": at_position
    }

    var famrland: Farmland = ResourceManager.load_resource("res://compoents/farmland/farmland.tscn").instantiate()
    famrland.global_position = at_position
    famrland.current = land
    farmlands.push_back(famrland)
    add_child(famrland)

    level_resource.farmland_exist_esource.lands.push_back(land)

    farmland_layer.set_cells_terrain_connect(get_all_farmland_cells(), 0, 0)

func get_farmland_from_position(at_position: Vector2) -> Farmland:
    var vi: Vector2i = UtilsManager.transform_position_tile(at_position)
    for farmland in farmlands:
        if vi == farmland.current["position"]:
            return farmland
    return null

func load_exist_farmland():
    if !level_resource.farmland_exist_esource || level_resource.farmland_exist_esource.lands.size() == 0:
        return
    
    for land in level_resource.farmland_exist_esource.lands:
        var famrland: Farmland = ResourceManager.load_resource("res://compoents/farmland/farmland.tscn").instantiate()
        famrland.global_position = land["position"]
        famrland.current = land
        farmlands.push_back(famrland)
        add_child(famrland)
    
    farmland_layer.set_cells_terrain_connect(get_all_farmland_cells(), 0, 0)

func get_all_farmland_cells():
    var cells: Array[Vector2i]

    for land in level_resource.farmland_exist_esource.lands:
        cells.push_back(land["cell"])
    return cells
#endregion

#region fellable_tree
func load_exist_fellable_tree():
    if !level_resource.fellable_tree_exist_resource || level_resource.fellable_tree_exist_resource.trees.size() == 0:
        return
    for tree in level_resource.fellable_tree_exist_resource.trees:
        var fellable_tree: FellableTree = ResourceManager.load_resource("res://compoents/fellable_tree/fellable_tree.tscn").instantiate()
        fellable_tree.global_position = tree["position"]
        fellable_tree.current = tree
        fellable_trees.push_back(fellable_tree)
        add_child(fellable_tree)

func get_fellable_tree_from_position(at_position) -> FellableTree:
    var vi: Vector2i = UtilsManager.transform_position_tile(at_position)
    for fellable_tree in fellable_trees:
        if vi == fellable_tree.current["position"]:
            return fellable_tree
    return null


func remove_fellable_tree(fellable_tree: FellableTree):
    fellable_trees = fellable_trees.filter(func(c): return c != fellable_tree)
    level_resource.fellable_tree_exist_resource.trees = level_resource.fellable_tree_exist_resource.trees.filter(func(c): return c["position"] != UtilsManager.transform_position_tile(fellable_tree.global_position))
    fellable_tree.queue_free()


#endregion
