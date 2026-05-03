@tool

extends EditorPlugin  

var main_screen_container: Control

var main_screen:InventoryEditor

func _has_main_screen() -> bool:
    return true

func _make_visible(visible: bool) -> void:
    if main_screen:
        main_screen.visible = visible

func _get_plugin_name() -> String:
    return "InventoryEditor"

func _get_plugin_icon() -> Texture2D:
    return preload("res://addons/inventory_editor/icon.atlastex")

func _enter_tree() -> void:
    main_screen_container = get_editor_interface().get_editor_main_screen()

    main_screen = preload("res://addons/inventory_editor/inventory_editor.tscn").instantiate()

    main_screen_container.add_child(main_screen)

    main_screen.visible = false

    main_screen_container.resized.connect(On_update_screen_size)

    scene_saved.connect(on_screen_saved)

    main_screen.on_update_size(main_screen_container.size)

func On_update_screen_size():
    if main_screen:
        main_screen.on_update_size(main_screen_container.size)

func on_screen_saved(e:String):
    print(e)