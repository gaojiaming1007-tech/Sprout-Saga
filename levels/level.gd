class_name Level

extends Node2D

@export var level_resource: LevelResource

@export var farmland_layer: TileMapLayer

enum LevelLocation {
    Outside,
    Inner
}

@export var level_location: LevelLocation = LevelLocation.Outside

var farmlands: Array[Farmland]

var fellable_trees: Array[FellableTree]

var astar := AStarGrid2D.new()

func _ready() -> void:
    GameManager.quit.connect(save)
    load_exist_farmland()
    load_exist_fellable_tree()
    load_buildings()
    load_astar()

func save():
    level_resource.last_position = GameManager.game.character.global_position
    ResourceManager.save_resource(level_resource)

func load_astar():
    astar.region = get_used_rect()
    astar.cell_size = farmland_layer.tile_set.tile_size
    astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.update()
    load_soild_cell()

func load_soild_cell():
    for x in range(astar.region.position.x, astar.region.end.x):
        for y in range(astar.region.position.y, astar.region.end.y):
            var coord = Vector2i(x, y)
            astar.set_point_solid(coord, false)
            for layer in get_all_tile_map_layers():
                var current_tile: TileMapLayer = layer
                if current_tile.get_cell_source_id(coord) != -1:
                    var data = current_tile.get_cell_tile_data(coord)
                    if data:
                        if data.has_custom_data("unwalkable") && data.get_custom_data("unwalkable"):
                            astar.set_point_solid(coord, true)
                            break

func get_used_rect() -> Rect2i:
    var combined_rect: Rect2i = Rect2i()
    var first_rect: bool = true

    for layer in get_all_tile_map_layers():
        var current_tile: TileMapLayer = layer
        if !current_tile.has_meta("bound_exclude"):
            var layer_rect: Rect2i = current_tile.get_used_rect()
            if first_rect:
                combined_rect = layer_rect
                first_rect = false
            else:
                combined_rect = combined_rect.merge(layer_rect)
    return combined_rect

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
                if data.has_custom_data("farmland") && data.get_custom_data("farmland") && !get_current_has_farmland(at_position) && !get_current_has_farmland(at_position) && !get_current_tile_can_axe(at_position) && !get_current_tile_has_builing(at_position):
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
                    fish = data.has_custom_data('fish') && data.get_custom_data('fish')
    return fish

func get_current_tile_has_fishing_bubble(at_position: Vector2):
    for tile in get_all_tile_map_layers():
        var current_tile: TileMapLayer = tile
        var cell = current_tile.local_to_map(current_tile.to_local(at_position))
        if current_tile.get_cell_source_id(cell) != -1:
            var data = current_tile.get_cell_tile_data(cell)
            if data:
                if data.has_custom_data("bubble") && data.get_custom_data("bubble"):
                    return true
    return false

func get_current_tile_can_building(at_position: Vector2):
    return !get_current_tile_can_axe(at_position) && !get_current_has_farmland(at_position) && !get_current_tile_has_builing(at_position)

func get_current_tile_has_builing(at_position: Vector2):
    if !level_resource.building_resource: return false
    var cell = building_layer.local_to_map(building_layer.to_local(at_position))
    for key in level_resource.building_resource.buildings:
        if level_resource.building_resource.buildings[key].has(cell):
            return true
    return false

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

    GameManager.game.range_prompt.set_shader_texture()

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

#region
func get_astar_path_to(start_position: Vector2, end_position: Vector2):
    var s = farmland_layer.local_to_map(to_local(start_position))
    var e = farmland_layer.local_to_map(to_local(end_position))
    var cells = astar.get_id_path(s, e)
    if cells.is_empty():
        return []
    else:
        var cell_path = cells.map(func(cell): return farmland_layer.to_global(farmland_layer.map_to_local(cell)))
        cell_path[0] = start_position
        cell_path[-1] = end_position
        return cell_path

#endregion

#region building
@export var building_layer: TileMapLayer
func add_building(at_position: Vector2, inventory_node: InventoryNode):
    var cell := building_layer.local_to_map(building_layer.to_local(at_position))
    var type: BuildingResource.BuildingType = inventory_node.current['inventory']['id'] % 8000
    if level_resource.building_resource.buildings.has(type):
        if level_resource.building_resource.buildings[type].has(cell):
            return
        level_resource.building_resource.buildings[type].push_back(cell)
    else:
        level_resource.building_resource.buildings[type] = [cell]
    building_layer.set_cells_terrain_connect(level_resource.building_resource.buildings[type], 0, type)

    if inventory_node.current['count'] == 1:
        inventory_node.current.clear()
    else:
        inventory_node.current['count'] -= 1

    inventory_node.update_display()

    if type == BuildingResource.BuildingType.Chest:
        add_chest(cell)

func add_chest(cell: Vector2i):
    var current = create_empty_chest()
    level_resource.building_resource.chests.set(cell, current)
    var chest: Chest = ResourceManager.load_resource("res://compoents/chest/chest.tscn").instantiate()
    chest.global_position = building_layer.to_global(building_layer.map_to_local(cell))
    chest.is_dynamic = true
    chest.dynamic_resource = current
    add_child(chest)


func create_empty_chest():
    var chest = []
    for i in range(16):
        chest.push_back({})
    var current: Dictionary = {
        "colums": 4,
        "chest": chest
    }
    return current

func load_buildings():
    if !level_resource.building_resource || level_resource.building_resource.buildings.size() == 0: return
    for key in level_resource.building_resource.buildings:
        building_layer.set_cells_terrain_connect(level_resource.building_resource.buildings[key], 0, key)

    for cell in level_resource.building_resource.chests:
        var chest: Chest = ResourceManager.load_resource("res://compoents/chest/chest.tscn").instantiate()
        chest.global_position = building_layer.to_global(building_layer.map_to_local(cell))
        chest.is_dynamic = true
        chest.dynamic_resource = level_resource.building_resource.chests[cell]
        add_child(chest)

#endregion
func get_current_tile_enable_to_move(at_position: Vector2):
    if !get_current_tile_inner_bound(at_position): return false
    var cell = farmland_layer.local_to_map(farmland_layer.to_local(at_position))
    return !astar.is_point_solid(cell)

func get_current_tile_inner_bound(at_position: Vector2):
    var bound: Rect2i = get_bound()
    return bound.has_point(at_position)
#region destination
