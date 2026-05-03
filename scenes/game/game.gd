class_name Game

extends Node2D

enum LevelType {
    Birth
}

const LEVEL_TYPE: Dictionary = {
    LevelType.Birth: "birth"
}

var current_level_instance: Level

@export var camera: Camera

@export var character: Character

@export var inventory_info_popup: InventoryInfoPopup

@export var time_record: TimeRecord

@export var game_resource: GameResource

@export var global_light: GlobalLight

@export var mouse_focus: MouseFocus

@export var range_prompt: RangePrompt

signal level_loaded

func _enter_tree() -> void:
    GameManager.game = self

func _exit_tree() -> void:
    GameManager.game = null

func _ready() -> void:
    load_level(game_resource.level)
    listen_events()

func listen_events():
    GameManager.quit.connect(
        func():
            ResourceSaver.save(game_resource, game_resource.resource_path)
    )

func load_level(level: LevelType):
    game_resource.level = level
    var load_need_level = func(callback: Callable):
        var level_path: String = "res://levels/%s/%s.tscn" % [LEVEL_TYPE[level], LEVEL_TYPE[level]]
        ResourceManager.load_resource_async(level_path,
         func(scene: Resource):
            var level_instance = scene.instantiate()

            if !level_instance: return

            if current_level_instance:
                current_level_instance.save()
                current_level_instance.queue_free()
                current_level_instance = null

            current_level_instance = level_instance
            add_child(current_level_instance)
            current_level_instance.set_character_postion()
            camera.set_limit()
            camera.set_follow_target(character)
            await get_tree().process_frame
            level_loaded.emit()
            callback.call(),
         func(process: float):
            print(process)
    )
    
    if current_level_instance:
        LoadingManager.enter(UtilsManager.get_screen_position(character.graphics).position, false, func():
            load_need_level.call(func():
                LoadingManager.leave(UtilsManager.get_screen_position(character.graphics).position)
            )
        )
    else:
        LoadingManager.enter_force()
        load_need_level.call(func():
            LoadingManager.leave(UtilsManager.get_screen_position(character.graphics).position)
            )

func switch_season(season: TimeRecord.Season):
    var switch = func():
        var tile_map_layers: Array[TileMapLayer] = []
        for child in current_level_instance.get_all_tile_map_layers():
            if child is TileMapLayer:
                print(child.get_meta_list())
                if child.has_meta("seasonal") && child.get_meta("seasonal"):
                    tile_map_layers.push_back(child)
       
        var season_tilest_resource: Resource = ResourceManager.load_resource("res://used/tileset/%s/%s.tres" % [TimeRecord.SEASON[season], TimeRecord.SEASON[season]])
        for layer in tile_map_layers:
            layer.tile_set = season_tilest_resource

    LoadingManager.enter(UtilsManager.get_screen_position(character.graphics).position, false, func():
        switch.call()
        LoadingManager.leave(UtilsManager.get_screen_position(character.graphics).position)
        )

func _process(_delta):
    ImGui.Begin("Debug")
    if ImGui.Button('Spring'):
        switch_season(TimeRecord.Season.Spring)
    if ImGui.Button('Summer'):
        switch_season(TimeRecord.Season.Summer)
    if ImGui.Button('Fall'):
        switch_season(TimeRecord.Season.Fall)
    if ImGui.Button('Winter'):
        switch_season(TimeRecord.Season.Winter)
    if ImGui.Button("Pickable"):
        var pickable: Pickable = ResourceManager.load_resource("res://compoents/pickable/pickable.tscn").instantiate()
        pickable.inventory = ResourceManager.load_resource("res://resources/inventory/weapon/hoe.tres")
        add_child(pickable)
    if ImGui.Button("AddFellableTree"):
        GameManager.game.current_level_instance.level_resource.fellable_tree_exist_resource.trees.push_back({
            "fellable_tree": load("res://resources/fellable_tree/maple/maple.tres"),
            "axe_count": 0,
            "position": UtilsManager.transform_position_tile(GameManager.game.character.global_position)
        })
    ImGui.End()
