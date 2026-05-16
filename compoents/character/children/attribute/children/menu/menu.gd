class_name Menu

extends InterfaceNode

@onready var attribute: Attribute = get_parent()

func on_click_item(item: String):
    if item == "Bag":
        attribute.task.reset()
        attribute.handbook.reset()
        attribute.bag.switch()
    elif item == "Task":
        attribute.bag.reset()
        attribute.handbook.reset()
        attribute.task.switch()
    elif item == "Handbook":
        attribute.task.reset()
        attribute.bag.reset()
        attribute.handbook.switch()
