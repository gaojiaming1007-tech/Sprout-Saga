class_name Farmland

extends Node2D

@export var sf: Sprite2D

@export var wet: Sprite2D

## { invetory:Inventory,moisture:float,growth_time:int,cell:Vector2i,position:Vector2i }
var current: Dictionary

var seed_resource: SeedResource

## 当前的生长阶段
var current_step = -1

func _ready() -> void:
    GameManager.game.time_record.time_update.connect(on_time_update)
    set_moisture()
    if current["inventory"] != null:
        seed_resource = ResourceManager.load_resource("res://resources/seed/%s.tres" % [current["inventory"]["id"]])
        set_sf()

func on_time_update():
    current["moisture"] = max(current["moisture"] - 0.01, 0)
    set_moisture()
    if current["inventory"] != null:
        current["growth_time"] += 1
        set_sf()

func to_saw(inventory_node: InventoryNode):
    current["inventory"] = inventory_node.current["inventory"]
    current["growth_time"] = 0
    current_step = -1

    if inventory_node.current["count"] == 1:
        inventory_node.current.clear()
        GameManager.game.character.attribute.hold.update_current_select(GameManager.game.character.character_resource.current_hold_select)
    else:
        inventory_node.current["count"] -= 1
        GameManager.game.range_prompt.set_shader_texture()
    
    inventory_node.update_display()

    seed_resource = ResourceManager.load_resource("res://resources/seed/%s.tres" % [current["inventory"]["id"]])
    set_sf()
    GameManager.game.range_prompt.set_shader_texture()
    
func set_sf():
    if current_step == seed_resource.groth_time_state.size():
        return
    if current["growth_time"] >= seed_resource.groth_time_state[-1]:
        current_step = seed_resource.groth_time_state.size()
        sf.texture = get_frame_from_sequence(seed_resource.sequence_frame)
        return

    for index in range(seed_resource.groth_time_state.size()):
        if current["growth_time"] < seed_resource.groth_time_state[index]:
            if current_step != index:
                current_step = index
                sf.texture = get_frame_from_sequence(seed_resource.sequence_frame)
            return

func get_frame_from_sequence(at: AtlasTexture):
    var atlas_texute = AtlasTexture.new()
    atlas_texute.atlas = at
    atlas_texute.region = Rect2(current_step * 16, 0, 16, 16)
    return atlas_texute

func to_watering():
    current["moisture"] = 1.0
    set_moisture()

func set_moisture():
    wet.visible = current["moisture"] > 0.5

func to_sickle():
    if current_step == seed_resource.groth_time_state.size():
        UtilsManager.drop_pickable(current["inventory"], 2, global_position + Vector2(8, 8))
        UtilsManager.drop_pickable(seed_resource.fruit, 3, global_position + Vector2(8, 8))
    else:
        var percent = float(current_step) / float(seed_resource.groth_time_state.size())
        if percent < 0.5:
            UtilsManager.drop_pickable(current["inventory"], 1, global_position + Vector2(8, 8))
        else:
            UtilsManager.drop_pickable(current["inventory"], 1, global_position + Vector2(8, 8))
            UtilsManager.drop_pickable(seed_resource.fruit, 1, global_position + Vector2(8, 8))

    current["inventory"] = null
    current["growth_time"] = 0
    sf.texture = null
