class_name CollectTaskDetailResource

extends Resource

## { inventory:Inventory, count:int,has:int }
@export var list: Array[Dictionary]

## 处理状态
func deal_done(npc: String):
    var done = true
    for t in list:
        var current: InventoryNode = GameManager.game.character.find_exist_item(t['inventory']['id'])
        if !current:
            t["has"] = 0
            done = false
            continue
        t['has'] = current.current['count']
        if t['has'] < t['count']:
            done = false
    return done

func pay():
    for t in list:
        var inventory_node: InventoryNode = GameManager.game.character.attribute.get_inventory_node(t['inventory'])
        if inventory_node.current['count'] == t['count']:
            inventory_node.current.clear()
        else:
            inventory_node.current['count'] -= t['count']
        inventory_node.update_display()
