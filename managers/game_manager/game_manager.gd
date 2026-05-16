extends Node

@export var game: Game

@export var setting_resource: SettingResource

## 哪些是需要存档的
@export var archive_resource_list: Array[String]


signal quit

func _ready() -> void:
    get_tree().set_auto_accept_quit(false)
    var io = ImGui.GetIO()
    io.ConfigFlags |= ImGui.ConfigFlags_DockingEnable


func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        on_quit()

func on_quit():
    quit.emit()
    ResourceManager.save_resource(setting_resource)
    save_to_archives()
    get_tree().quit()

func save_to_archives():
    if setting_resource.current_existing_index == -1: return
    for r in archive_resource_list:
        var prop_name = r.split('/')[-1].split('.tres')[0]
        ResourceSaver.save(ResourceManager.load_resource(r), "res://archives/%s/%s.tres" % [setting_resource.current_existing_index, prop_name])

func pause():
    get_tree().paused = true

func resume():
    get_tree().paused = false
