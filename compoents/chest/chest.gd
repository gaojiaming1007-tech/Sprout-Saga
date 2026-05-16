class_name Chest

extends Node2D

@export var animtion_player: AnimationPlayer

@export var interact: Control

var is_enter: bool = false

var is_open: bool = false

@export var layer: CanvasLayer

@export var root: PanelContainer

@export var grid_container: GridContainer

@export var chest_resource: ChestResource

var is_dynamic: bool = false

var dynamic_resource: Dictionary

var tween: Tween

func _ready() -> void:
    interact.visible = false
    layer.visible = false
    to_load_items()
    GameManager.quit.connect(save)

func _exit_tree() -> void:
    save()

func save():
    if !is_dynamic:
        ResourceManager.save_resource(chest_resource)

func _process(_delta: float) -> void:
    if is_enter && Input.is_action_just_pressed("Chest"):
        if is_open:
            ToClose()
        else:
            ToOpen()

func _on_character_entered(body: Node2D) -> void:
     if body is Character:
        is_enter = true
        interact.visible = true

func _on_character_exited(body: Node2D) -> void:
    if body is Character:
        is_enter = false
        interact.visible = false
        ToClose()

func to_get_resource():
    if is_dynamic:
        return dynamic_resource
    return chest_resource

func to_load_items():
    var resource = to_get_resource()
    grid_container.columns = resource.colums
    for i in range(resource.chest.size()):
        var item: ChestItem = ResourceManager.load_resource("res://compoents/chest/children/chest_item/chest_item.tscn").instantiate()
        item.current = resource.chest[i]
        grid_container.add_child(item)

func ToOpen():
    is_open = true
    layer.visible = true

    root.scale.x = 0

    var show_positon = UtilsManager.get_screen_position(self ).canvas_position + Vector2(10, -root.size.y / 2)
    if GameManager.game.character.attribute.bag.visible:
        show_positon.x = max(show_positon.x, GameManager.game.character.attribute.bag.panel.size.x + GameManager.game.character.attribute.bag.panel.position.x + 10)
    root.position = show_positon

    SoundManager.player_audio(SoundManager.AudioType.Chest_Open, -10.0, 0.09, SoundManager.AudioGrade.Chest)

    if tween:
        tween.kill()
    tween = create_tween().set_parallel(true)
    tween.tween_property(root, "scale:x", 1, 0.1)
    animtion_player.play('open')


func ToClose():
    if is_open:
        is_open = false

        SoundManager.player_audio(SoundManager.AudioType.Chest_Closed, -10, 0.09, SoundManager.AudioGrade.Chest)

        if tween:
            tween.kill()

        tween = create_tween().set_parallel(true)
        tween.tween_property(root, "scale:x", 0, 0.1)
        await tween.finished
        layer.visible = false
        animtion_player.play('closed')
