class_name Handbook

extends InterfaceNode

@export var inventory_list_resource: InventoryList

var tween: Tween

var type_list: Array[TextureButton] = []

var current_type: Inventory.InventoryType = Inventory.InventoryType.Building

var current_type_inventory_list: Array[Inventory] = []

var current_page = 1

var handbook_item_list: Array[HandbookItem] = []

func _enter_tree():
    for child in %HandbookContainer.get_children():
        if child is TextureButton:
            child.pressed.connect(on_select_type.bind(int(child.name)))
            type_list.push_back(child)
    reset()

func _ready() -> void:
    on_select_type(Inventory.InventoryType.Weapon, false)

func switch():
    if tween:
        tween.kill()
    tween = create_tween().set_parallel(true)
    if !visible:
        visible = true
        tween.tween_property(self , "modulate:a", 1.0, 0.1)
    else:
        tween.tween_property(self , "modulate:a", 0.0, 0.1)
        tween.finished.connect(func(): visible = false)

func reset():
    if tween:
        tween.kill()
    visible = false
    modulate.a = 0.0

func on_select_type(type: Inventory.InventoryType, audio: bool = true):
    if type == current_type: return
    if audio: SoundManager.player_audio(SoundManager.AudioType.UI_Click, -3, 0.01, SoundManager.AudioGrade.UI)
    current_type = type
    current_type_inventory_list = inventory_list_resource.list.filter(func(c: Inventory): return c.type == type)
    current_type_inventory_list.sort_custom(func(a: Inventory, b: Inventory): return a["id"] < b["id"])
    type_list[current_type].grab_focus()
    current_page = 1
    draw_list()
    update_button_visibilty()

func draw_list():
    for e in handbook_item_list:
        e.queue_free()
    handbook_item_list.clear()
    var current := current_type_inventory_list.slice((current_page - 1) * 32, current_page * 32)
    for i in range(current.size()):
        var item: HandbookItem = ResourceManager.load_resource("res://compoents/character/children/attribute/children/handbook/children/handbook_item.tscn").instantiate()
        item.current = {
            "inventory": current[i],
            "count": 1
        }
        handbook_item_list.push_back(item)
        if i < 16:
            %Left.add_child(item)
        elif i < 32:
            %Right.add_child(item)


func update_button_visibilty():
    if current_type_inventory_list.size() < 32:
        %ForwardButton.visible = false
        %BackwardButton.visible = false
    else:
        %ForwardButton.visible = current_page * 32 < current_type_inventory_list.size()
        %BackwardButton.visible = !current_page == 1


func _on_forward_pressed() -> void:
    current_page += 1
    draw_list()
    update_button_visibilty()

func _on_backward_pressed() -> void:
    current_page -= 1
    draw_list()
    update_button_visibilty()
