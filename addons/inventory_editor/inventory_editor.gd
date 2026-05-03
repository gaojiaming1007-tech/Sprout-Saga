@tool

class_name InventoryEditor

extends Control

@export var inventory_list: InventoryList

@export var inventory_item: PackedScene

var children: Array[InventoryItem] = []

var current_inventory: Inventory

var timer: Timer

var select_dialog: EditorFileDialog

var save_dialog: EditorFileDialog

var is_highlight = false

func on_update_size(size: Vector2):
    %Root.size = size

func _enter_tree() -> void:
    %TextureButton.pressed.connect(on_click_texture)
    %HighlightButton.pressed.connect(on_click_highlight_texture)
    %ID.value_changed.connect(func(e): to_save_inventory())
    %Name.text_changed.connect(func(): to_save_inventory())
    %Description.text_changed.connect(func(): to_save_inventory())
    %Type.item_selected.connect(func(e): to_save_inventory())
    %Price.value_changed.connect(func(e): to_save_inventory())
    %Stack.pressed.connect(func(): to_save_inventory())
    %Lift.pressed.connect(func(): to_save_inventory())
    %Add.pressed.connect(on_click_add)
    reload_list()
    setup_select_dialog()
    setup_save_dialog()
    set_timer()

func setup_select_dialog():
    select_dialog = EditorFileDialog.new()
    select_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    select_dialog.access = EditorFileDialog.ACCESS_RESOURCES
    select_dialog.current_dir = "res://used/inventort"
    select_dialog.add_filter("*.atlastext", "Atlas Texture Files")
    select_dialog.file_selected.connect(on_file_select)
    add_child(select_dialog)

func on_file_select(path: String):
    var at := load(path) as AtlasTexture
    if at:
        if is_highlight:
            %HightlightTexture.texture = at
        else:
            %Texture.texture = at
        to_save_inventory()

func setup_save_dialog():
    save_dialog = EditorFileDialog.new()
    save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
    save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
    save_dialog.current_dir = "res://resources/inventory"
    save_dialog.current_file = "new_inventory.tres"

    save_dialog.add_filter("*.tres", "Godot Resource Files")
    save_dialog.file_selected.connect(on_save_file_select)
    add_child(save_dialog)

func on_save_file_select(path: String):
    var new_inventory = Inventory.new()
    ResourceSaver.save(new_inventory, path)
    inventory_list.list.push_front(load(path))
    ResourceSaver.save(inventory_list, inventory_list.resource_path)
    reload_list()

func on_click_add():
    save_dialog.popup_centered_ratio(0.8)

func set_timer():
    timer = Timer.new()
    timer.one_shot = true
    timer.autostart = false
    timer.wait_time = 0.3
    timer.timeout.connect(timer_over_to_save)
    add_child(timer)

func to_save_inventory():
    timer.start()

func timer_over_to_save():
    if !current_inventory: return
    current_inventory["id"] = int(%ID.value)
    current_inventory["texture"] = %Texture.texture
    current_inventory["highlight_texture"] = %HightlightTexture.texture
    current_inventory["name"] = %Name.text
    current_inventory["description"] = %Description.text
    current_inventory["type"] = %Type.selected
    current_inventory["price"] = int(%Price.value)
    current_inventory["stack"] = %Stack.button_pressed
    current_inventory["lift"] = %Lift.button_pressed
    for child in children:
        if child.inventory == current_inventory:
            child.update()
            break
    ResourceSaver.save(current_inventory, current_inventory.resource_path)

func on_click_texture():
    is_highlight = false
    select_dialog.popup_centered_ratio(0.8)

func on_click_highlight_texture():
    is_highlight = true
    select_dialog.popup_centered_ratio(0.8)

func reload_list():
    for child in children:
        child.queue_free()
    children.clear()

    for item in inventory_list.list:
        var c: InventoryItem = inventory_item.instantiate()
        %ListContainer.add_child(c)
        c.set_default(item, self )
        children.push_back(c)

    children[0].on_click()

func set_current(new_inventory: Inventory):
    current_inventory = new_inventory
    %ID.value = current_inventory["id"]
    %Texture.texture = current_inventory["texture"]
    %HightlightTexture.texture = current_inventory["highlight_texture"]
    %Name.text = current_inventory["name"]
    %Description.text = current_inventory["description"]
    %Type.selected = current_inventory["type"]
    %Price.value = current_inventory["price"]
    %Stack.button_pressed = current_inventory["stack"]
    %Lift.button_pressed = current_inventory["lift"]
