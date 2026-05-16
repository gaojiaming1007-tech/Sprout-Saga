class_name Celebrate

extends CanvasLayer

@export var root: PanelContainer

var label: String

## { inventory:Inventory, count:int }
var list: Array[Dictionary]

var tween: Tween

var is_input: bool = false

signal finish

func _enter_tree() -> void:
    root.modulate.a = 0.0

func _ready() -> void:
    %Label.text = label
    for item in list:
        var award_inventory: AwardInventory = ResourceManager.load_resource("res://managers/prompt_manager/children/celebrate/children/award_inventory/award_inventory.tscn").instantiate()
        award_inventory.current = item
        %RewardContainer.add_child(award_inventory)
    tween = create_tween()
    tween.tween_property(root, "modulate:a", 1.0, 0.1)

func _process(_delta: float) -> void:
    if !is_input && Input.is_action_just_pressed("accpet"):
        is_input = true
        if tween:
            tween.kill()
        tween = create_tween()
        tween.tween_property(root, "modulate:a", 0.0, 0.1)
        await tween.finished
        finish.emit()
