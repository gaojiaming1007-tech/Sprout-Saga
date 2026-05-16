extends Node

enum Scene {
    Main,
    Game,
    # Prologue
}

const SCENE_NAME = {
    Scene.Main: 'res://scenes/main/main.tscn',
    Scene.Game: 'res://scenes/game/game.tscn',
    # Scene.Prologue: 'res://scenes/prologue/prologue.tscn',
}

signal scene_changed(scene: Scene)

func switch_scene(scene: Scene):
    ResourceManager.load_resource_async(SCENE_NAME[scene],
        func(scene_resource: PackedScene):
            get_tree().change_scene_to_packed(scene_resource)
            scene_changed.emit(scene),
        func(process: float):
            pass
    )

func _ready() -> void:
    scene_changed.emit(Scene.Main)
