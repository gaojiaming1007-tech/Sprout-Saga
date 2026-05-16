extends Node

var is_celebrate: bool = false

func start_celebrate(label: String, inventory_list: Array[Dictionary]):
    is_celebrate = true
    var celebrate: Celebrate = ResourceManager.load_resource("res://managers/prompt_manager/children/celebrate/celebrate.tscn").instantiate()
    celebrate.label = label
    celebrate.list = inventory_list
    add_child(celebrate)
    await celebrate.finish
    for item in inventory_list:
        GameManager.game.character.add_inventort(item['inventory'], item['count'])
    celebrate.queue_free()
    is_celebrate = false

func message(node: Node2D, at: AtlasTexture, content: String):
    var item: Message = ResourceManager.load_resource("res://managers/prompt_manager/children/message/message.tscn").instantiate()
    item.set_default(UtilsManager.get_screen_position(node).canvas_position, at, content)
    add_child(item)
