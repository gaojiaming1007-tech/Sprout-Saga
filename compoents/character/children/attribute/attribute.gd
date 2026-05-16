class_name Attribute

extends CanvasLayer

@onready var character: Character = get_parent()

@export var bag: Bag

@export var hold: Hold

@export var menu: Menu

@export var task: Task

@export var handbook: Handbook

## 获取第一个所需要物品的背包节点
func get_inventory_node(target: Inventory):
    for item in bag.bag_item_list:
        if item.current.size() != 0 && item.current['inventory'] == target:
            return item
    
    for item in hold.hold_item_list:
        if item.current.size() != 0 && item.current['inventory'] == target:
            return item
    return null
