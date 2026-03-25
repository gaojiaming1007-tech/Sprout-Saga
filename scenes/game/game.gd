class_name Game

extends Node2D

enum LevelTpye{
    Birth
}

const LEVEL_TYPE:Dictionary = {
    LevelTpye.Birth:"birth"
}

enum Season{
    Spring,
    Summer,
    Fall,
    Winter
}

const SEASON = {
    Season.Spring : 'spring',
    Season.Summer : 'summer',
    Season.Fall : 'fall',
    Season.Winter : 'winter',
}

var current_level_instance:Level

@export var camera:Camera

@export var character:Character

signal level_loaded

func _enter_tree()->void:
    GameManager.game = self

func _exit_tree()->void:
    GameManager.game = null

func _ready()->void:
    load_level(LevelTpye.Birth)

func load_level(level:LevelTpye):
    var load_need_level = func(callback:Callable):
        var level_path: String = "res://levels/%s/%s.tscn"%[LEVEL_TYPE[level],LEVEL_TYPE[level]]
        ResourceManager.load_resource_async(level_path,
         func(scene: Resource):
            current_level_instance = scene.instantiate()
            add_child(current_level_instance)
            camera.set_limit()
            camera.set_follow_target(character)
            level_loaded.emit()
            callback.call(),
         func(process: float):
            print(process)
    )
    
    if current_level_instance:
        LoadingManager.enter(Vector2(0.5,0.5),false,func():
            load_need_level.call(func():
                LoadingManager.leave(Vector2(0.5,0.4))
            )
        )
    else:
        LoadingManager.enter_force()
        load_need_level.call(func():
            LoadingManager.leave(Vector2(0.5,0.5))
            )


func switch_seaon(season:Season):
    var switch = func():
        var tile_map_layers:Array[TileMapLayer] = []
        for child in current_level_instance.get_all_tile_map_layers():
            if child is TileMapLayer:
                print(child.get_meta_list())
                if child.has_meta("seasonal")&&child.get_meta("seasonal"):
                    tile_map_layers.push_back(child)

        print(tile_map_layers)
       
        var season_tilest_resource:Resource = ResourceManager.load_resource("res://used/tileset/%s/%s.tres"%[SEASON[season],SEASON[season]])
        for layer in tile_map_layers:
            layer.tile_set = season_tilest_resource 

    LoadingManager.enter(Vector2(0.5,0.5),false,func():
        switch.call()
        LoadingManager.leave(Vector2(0.5,0.5))
        )

func _process(_delta):
    ImGui.Begin("Debug")
    if ImGui.Button('Spring'):
        switch_seaon(Season.Spring)
    if ImGui.Button('Summer'):
        switch_seaon(Season.Summer)
    if ImGui.Button('Fall'):
        switch_seaon(Season.Fall)
    if ImGui.Button('Winter'):
        switch_seaon(Season.Winter)
    ImGui.End()
