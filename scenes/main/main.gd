class_name Main

extends Node2D

enum MainType {
    Game,
    Explain,
    Setting,
    Quit
}

const MAIN_TYPE = {
    MainType.Game: "游戏",
    MainType.Explain: "说明",
    MainType.Setting: "设置",
    MainType.Quit: "退出",
}

# @export var audio: AudioStreamPlayer

var buttons: Array[ClassifyButton] = []

var current_type: MainType = MainType.Quit

@export var zones: Array[Control]

@export var existing: Control

@export var existing_buttons: Array[MainButton] = []

@export var volume_slider: HSlider

func _ready() -> void:
    for button in %Classify.get_children():
        if button is ClassifyButton:
            button.click.connect(on_classify_button_click.bind(int(button.name)))
            buttons.push_back(button)
    on_classify_button_click(MainType.Game, true)
    volume_slider.value = GameManager.setting_resource.volume

func on_classify_button_click(type: MainType, first: bool = false):
    if type == current_type:
        return
    if type == MainType.Quit:
        GameManager.on_quit()
    else:
        if !first:
            buttons[current_type].reset()
        buttons[type].focus()
        current_type = type
        existing.visible = false

        for zone in zones:
            zone.visible = false
        zones[current_type].visible = true


func _on_new_game_pressed() -> void:
    var access = DirAccess.open("res://archives")
    var current_index = access.get_directories().size() + 1
    access.make_dir("res://archives/%s" % [current_index])
    for r in GameManager.archive_resource_list:
        var prop_name = r.split('/')[-1].split('.tres')[0]
        ResourceSaver.save(ResourceManager.load_resource(r).get_script().new(), "res://archives/%s/%s.tres" % [current_index, prop_name])
    to_load_existing(current_index, true)

func _on_existing_pressed() -> void:
    existing.visible = true
    for button in existing_buttons:
        button.queue_free()
    existing_buttons.clear()
    zones[current_type].visible = false
    var dirs := DirAccess.open("res://archives/").get_directories()
    for i in dirs:
        var item: MainButton = ResourceManager.load_resource("res://scenes/main/children/main_button/main_button.tscn").instantiate()
        var index = int(i)
        item.name = str(index)
        item.text = "存档%s" % [index]
        item.pressed.connect(to_load_existing.bind(index))
        %List.add_child(item)
        existing_buttons.push_back(item)

func to_load_existing(index: int, new_game: bool = false):
    GameManager.setting_resource.current_existing_index = index
    for r in GameManager.archive_resource_list:
        var prop_name = r.split('/')[-1].split('.tres')[0]
        ResourceSaver.save(ResourceManager.load_resource("res://archives/%s/%s.tres" % [index, prop_name]), r)
    if !new_game:
        LoadingManager.enter(Vector2(0.5, 0.5), false, func(): SceneManager.switch_scene(SceneManager.Scene.Game))
    else:
        LoadingManager.enter(Vector2(0.5, 0.5), false, func(): SceneManager.switch_scene(SceneManager.Scene.Game))


func _on_back_pressed() -> void:
    existing.visible = false
    zones[current_type].visible = true


func _on_volume_changed(value: float) -> void:
    GameManager.setting_resource.volume = value
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -20 + value)
    # audio.volume_db = -10 + lerp(-20, 20, value)
