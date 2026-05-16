class_name Character

extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO

var is_run: bool = false

@export var animation_tree: AnimationTree

@export var graphics: Node2D

@export var sprite: Sprite2D

func _ready() -> void:
    is_steed = character_resource.current_steed_type != SteedType.None
    listen_events()

func _exit_tree() -> void:
    on_quit()

func listen_events():
    GameManager.quit.connect(on_quit)
    Dialogic.signal_event.connect(on_dialogue_signal_event)

func _process(_delta):
    get_input_values()
    distribute_input()

func is_interfact_state():
    return current_action_state == ActionState.Default || current_action_state == ActionState.Lift || current_action_state == ActionState.Steed

func get_input_values():
    if is_interfact_state() && !LoadingManager.is_loading && !is_dialogue && !PromptManager.is_celebrate && !UtilsManager.is_shop:
        direction = Input.get_vector('left', 'right', 'backward', 'forward')
    else:
        direction = Vector2.ZERO
    is_run = Input.is_action_pressed('run')

func distribute_input():
    if Input.is_action_just_pressed("pick"):
        on_pick()
    if Input.is_action_just_pressed("reel"):
        on_reel()
    if Input.is_action_just_pressed("steed"):
        exit_steed()

func _physics_process(delta):
    movement()
    set_action_state()
    set_face_direction()
    set_movement_state()
    transform_graphics_scale()
    update_lift_visible()
    move_and_slide()

#region
@export_group("resource")
@export var character_resource: CharacterResource

func on_quit():
    character_resource.current_hold_select = attribute.hold.current_select
    ResourceManager.save_resource(character_resource)
    
#endregion
#region movement
@export_group("movement")
@export var walk_speed: float = 3.0

@export var run_speed: float = 6.0

enum ActionState {
    ##默认状态
    Default,
    ##举起状态
    Lift,
    ##钓鱼等待
    FishingWait,
    ##钓鱼上钩
    FishingHooked,
    Steed,
    OneShot
}

const ACTION_STATE = {
    ActionState.Default: 'default',
    ActionState.Lift: 'lift',
    ActionState.FishingWait: 'fishing_wait',
    ActionState.FishingHooked: 'fishing_hooked',
    ActionState.Steed: 'steed'
}

enum MovementState {
    Idle = -1,
    Walk,
    Run
}

const MOVEMENT_STATE = {
    MovementState.Idle: 'idle',
    MovementState.Walk: 'walk',
    MovementState.Run: 'run'
}

enum FaceDirection {
    Forward = -1,
    Backward,
    Parallel
}

const FACE_DIRECTION = {
    FaceDirection.Forward: 'forward',
    FaceDirection.Backward: 'backward',
    FaceDirection.Parallel: 'parallel'
}

enum OneShotState {
    ##捡起
    Collect,
    ##锄地
    Hoe,
    ##浇水
    Watering,
    Sickle,
    Axe,
    ##钓鱼抛竿
    FishingCasting,
    ##收竿没有鱼
    FishingCaptureNoFish,
    ##收竿有鱼
    FishingCaptureFish,
    ##钓鱼收杆
    FishingRoll,
    Petting
}

const ONESHOT_STATE = {
    OneShotState.Collect: 'collect',
    OneShotState.Hoe: 'hoe',
    OneShotState.Watering: 'watering',
    OneShotState.Sickle: 'sickle',
    OneShotState.Axe: 'axe',
    OneShotState.FishingCasting: 'fishing_casting',
    OneShotState.FishingCaptureNoFish: 'fishing_capture_no_fish',
    OneShotState.FishingCaptureFish: 'fishing_capture_fish',
    OneShotState.FishingRoll: 'fishing_roll',
    OneShotState.Petting: 'petting',
}

var current_action_state: ActionState = ActionState.Default

var current_face_direction: FaceDirection = FaceDirection.Forward

var current_movement_state: MovementState = MovementState.Idle

func movement():
    if current_action_state == ActionState.Steed:
        velocity = direction * (walk_speed if !is_run else run_speed) * 80
    else:
        velocity = direction * (walk_speed if !is_run else run_speed) * 40

func transform_graphics_scale():
    if !is_zero_approx(direction.x):
        graphics.scale.x = 1.0 if direction.x > 0.0 else -1.0

func set_action_state():
    if current_action_state == ActionState.OneShot:
        return
    if is_fishing:
        current_action_state = ActionState.FishingHooked if is_hooked else ActionState.FishingWait
        return
    if character_resource.current_steed_type != SteedType.None:
        current_action_state = ActionState.Steed
        return
    var inventory = attribute.hold.get_current_select()
    if inventory && inventory["lift"]:
        current_action_state = ActionState.Lift
    else:
        current_action_state = ActionState.Default

func set_face_direction():
    if !direction.is_zero_approx():
        if !is_zero_approx(direction.x):
            current_face_direction = FaceDirection.Parallel
        else:
            current_face_direction = FaceDirection.Forward if direction.y > 0.0 else FaceDirection.Backward

func set_movement_state():
    if direction.is_zero_approx():
        if current_movement_state != MovementState.Idle:
            SoundManager.stop_grade(SoundManager.AudioGrade.Footsteps)
        current_movement_state = MovementState.Idle
    else:
        current_movement_state = MovementState.Run if is_run else MovementState.Walk

func update_face_direction(p1: Vector2):
    current_face_direction = UtilsManager.get_direction_from_position(p1, global_position)
    if current_face_direction == FaceDirection.Parallel:
        graphics.scale.x = 1.0 if p1.x > global_position.x else -1.0

func update_position_to_center():
    var center_position = UtilsManager.transform_position_tile(global_position) + Vector2i(8, 8)
    global_position = center_position
    velocity = Vector2.ZERO

#endregion

#region farmland

signal hoe_target

func emit_hoe_target():
    SoundManager.player_audio(SoundManager.AudioType.Hoe, -10)
    hoe_target.emit()

signal watering_target

func emit_watering_target():
    SoundManager.player_audio(SoundManager.AudioType.Watering, 0, 1.2)
    watering_target.emit()

signal sickle_target

func emit_sickle_target():
    SoundManager.player_audio(SoundManager.AudioType.Sickle, -10, 0.04)
    sickle_target.emit()

signal fishing_casting_target

func emit_fishing_casting_target():
    SoundManager.player_audio(SoundManager.AudioType.FishingCasting, -10, 0.08)
    fishing_casting_target.emit()

#endregion

#endregion

#region fellable_tree

signal axe_target

func emit_axe_target():
    SoundManager.player_audio(SoundManager.AudioType.Axe, -10)
    GameManager.game.camera.shake()
    axe_target.emit()

#region attribute

@export var attribute: Attribute

#endregion

#region lift
@export_group("lift")
@export var lift_sprite: Sprite2D

func update_lift_visible():
    if lift_sprite.texture:
        lift_sprite.visible = current_action_state == ActionState.Lift
    else:
        lift_sprite.visible = false
#endregion

#region interact
@export_group("interact")
@export var interact: Interact

#endregion

#region pickable

var pickable_list: Array[Pickable] = []

func on_pickable_enter(p: Pickable):
    pickable_list.push_back(p)

func on_pickable_leave(p: Pickable):
    pickable_list = pickable_list.filter(func(c): return c != p)

func on_pick():
    if interact.current_keyboard_type == Interact.KeyboardType.Pickable:
        pick_pickable()

func pick_pickable():
    var pick := pickable_list[0]
    animation_state.start_one_shot(OneShotState.Collect)
    var result = add_inventort(pick.inventory, pick.count)
    if result:
        PromptManager.message(lift_sprite, pick.inventory.texture, "%s" % [pick.inventory.name])
        pick.queue_free()

func add_inventort(inventory: Inventory, count: int):
    var current: InventoryNode

    if !inventory['stack']:
        current = find_can_use_item()
        if current == null:
            UtilsManager.drop_pickable(inventory, count, global_position)
        else:
            current.current['inventory'] = inventory
            current.current['count'] = 1
            if count > 1:
                add_inventort(inventory, count - 1)
    else:
        current = find_exist_item(inventory['id'])
        if current == null:
            current = find_can_use_item()
            if current == null:
                UtilsManager.drop_pickable(inventory, count, global_position)
            else:
                current.current['inventory'] = inventory
                current.current['count'] = count
        else:
            current.current['count'] += count
    if current:
        current.update_display()
    return current

func find_exist_item(id: int):
    for c in attribute.bag.bag_item_list:
        if c.current.size() != 0 && c.current['inventory']['id'] == id:
            return c
    for c in attribute.hold.hold_item_list:
        if c.current.size() != 0 && c.current['inventory']['id'] == id:
            return c
    return null

func find_can_use_item():
    for c in attribute.bag.bag_item_list:
        if c.current.size() == 0:
            return c
    for c in attribute.hold.hold_item_list:
        if c.current.size() == 0:
            return c
    return null
#endregion

#region pickable
@export_group("animation_state")
@export var animation_state: AnimationState
#endregion

#region fishing
@export_group("fishing")
@export var roll_energy_parent: Marker2D

@export var carp: Inventory

var is_fishing: bool = false

var is_hooked: bool = false

var fishing_timer: Timer

func enter_fishing(at_position: Vector2):
    is_fishing = true
    is_hooked = false
    set_fish_wait_timer(at_position)

func set_fish_wait_timer(at_position: Vector2):
    fishing_timer = Timer.new()
    fishing_timer.one_shot = true
    fishing_timer.wait_time = 2 if GameManager.game.current_level_instance.get_current_tile_has_fishing_bubble(at_position) else 10
    fishing_timer.autostart = true
    add_child(fishing_timer)
    await fishing_timer.timeout
    is_hooked = true
    fishing_timer.queue_free()


func on_reel():
    if is_fishing && !UtilsManager.is_roll_energy:
        if is_hooked:
            on_fish()
        else:
            on_no_fish()

func on_fish():
    var on_energy = func(delta: float):
        if delta < 0.3:
            await animation_state.start_one_shot(OneShotState.FishingRoll)
            await animation_state.start_one_shot(OneShotState.FishingCaptureFish)
            exit_fishing()
            on_get_fish()
        else:
            on_no_fish()

    UtilsManager.start_roll_energy(on_energy, roll_energy_parent, randf())

func on_no_fish():
    await animation_state.start_one_shot(OneShotState.FishingRoll)
    await animation_state.start_one_shot(OneShotState.FishingCaptureNoFish)
    exit_fishing()

func on_get_fish():
    add_inventort(carp, 1)

func exit_fishing():
    is_fishing = false
    is_hooked = false
    if fishing_timer:
        fishing_timer.queue_free()
#endregion

#region dialogue

var is_dialogue: bool = false

func on_dialogue_timeline_started(timeline: String):
    is_dialogue = true
    if timeline.begins_with("boatman"):
        on_boatman_dialogue()

func on_boatman_dialogue():
    Dialogic.VAR.boatman.task_state = attribute.task.get_task_state(1)
    Dialogic.VAR.boatman.current_level = Game.LEVEL_TYPE[GameManager.game.game_resource.level]

func on_dialogue_timeline_ended(timeline: String):
    is_dialogue = false
    attribute.task.refresh_task_state(timeline.split("_")[0])

func on_dialogue_signal_event(e: Dictionary):
    if e['type'] == 'add_task':
        attribute.task.to_add_task(int(e['id']))
    elif e['type'] == 'over_task':
        attribute.task.to_over_task(int(e['id']))
    elif e['type'] == 'transfer':
        to_transfer(int(e['target_level']))
    elif e['type'] == 'shop':
        to_shop(int(e['npc']))

func to_shop(npc: NPC.NpcType):
    await UtilsManager.start_shop(ResourceManager.load_resource("res://resources/shop/%s_shop_resource.tres" % [NPC.NPC_TYPE[npc]]))
    attribute.task.refresh_task_state(NPC.NPC_TYPE[npc])

func to_transfer(level: Game.LevelType):
    GameManager.game.load_level(level)


#endregion
#region audio
func play_footsteps():
    SoundManager.player_audio(SoundManager.AudioType.Footsteps_Grass, -20, 0.0, SoundManager.AudioGrade.Footsteps)
#endregion

#region shop
func to_buy_inventory(inventory: Inventory, count: int):
    var price = inventory.price * count
    if character_resource.money > price:
        var current = add_inventort(inventory, count)
        if current:
            character_resource.money -= price
    else:
        pass

func selling_inventory(target: InventoryNode, count: int):
    character_resource.money += int(target.current['inventory']['price'] * count * 0.8)
    if target.current['count'] == count:
        target.current.clear()
    else:
        target.current['count'] -= count
    target.update_display()
#endregion

#region
enum SteedType {
    None = -1,
    Horse
}

const STEED_TYPE: Dictionary = {
    SteedType.Horse: 'horse'
}

var is_steed: bool = false

func switch_steed(npc: NPC):
    if character_resource.current_steed_type != SteedType.None:
        return
    if npc is Horse:
        global_position = npc.global_position
        character_resource.current_steed_type = SteedType.Horse
    npc.queue_free()
    await get_tree().create_timer(0.1).timeout
    is_steed = true

func exit_steed():
    if !is_steed || character_resource.current_steed_type == SteedType.None: return
    free_last_steed()
    character_resource.current_steed_type = SteedType.None
    is_steed = false

func free_last_steed():
    if character_resource.current_steed_type == SteedType.Horse:
        var horse: Horse = ResourceManager.load_resource("res://compoents/npc/horse/horse.tscn").instantiate()
        horse.global_position = global_position
        get_parent().add_child(horse)

#endregion
