@tool

class_name InventoryItem

extends Control

var editor: InventoryEditor

var inventory: Inventory

func _enter_tree() -> void:
    $Button.pressed.connect(on_click)

func on_click():
    editor.set_current(inventory)

func set_default(target_inventory: Inventory, target_editor: InventoryEditor):
    editor = target_editor
    inventory = target_inventory
    $Button.icon = inventory["texture"]
    $Button.text = inventory["name"]

func update():
    $Button.icon = inventory["texture"]
    $Button.text = inventory["name"]
