class_name Level

extends Node

func get_all_tile_map_layers():
    return find_child("TileMapLayerContianer",false,false).get_children()
