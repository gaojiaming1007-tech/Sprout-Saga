class_name Level

extends Node

func get_all_tile_map_layers():
    return find_child("TileMapLayerContianer",false,false).get_children()

func get_bound():
    var min_x = INF
    var min_y = INF
    var max_x = -INF
    var max_y = -INF

    for layer in get_all_tile_map_layers():
        var tile:TileMapLayer = layer
        var map_rect:Rect2i = tile.get_used_rect()
        var tile_size:Vector2i = tile.tile_set.tile_size
        var world_size := map_rect.size * tile_size
        var world_position := map_rect.position * tile_size
        min_x = min(min_x,world_position.x)
        min_y = min(min_y,world_position.y)
        max_x = max(max_x,world_position.x + world_size.x)
        max_y = max(max_y,world_position.y + world_size.y)

    return Rect2i(min_x,min_y,max_x - min_x,max_y - min_y)
