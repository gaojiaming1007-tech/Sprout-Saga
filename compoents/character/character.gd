class_name Character

extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO

var is_run: bool = false

@export var animation_tree: AnimationTree

@export var graphics: Node2D

@export var sprite: Sprite2D

func _ready() -> void:
    listen_events()

func _exit_tree() -> void:
    on_quit()

func listen_events():
    GameManager.quit.connect(on_quit)

func _process(_delta):
    get_input_values()
    distribute_input()

func is_interfact_state():
    return current_action_state == ActionState.Default || current_action_state == ActionState.Lift

func get_input_values():
    if is_interfact_state() && !LoadingManager.is_loading:
        direction = Input.get_vector('left', 'right', 'backward', 'forward')
    is_run = Input.is_action_pressed('run')

func distribute_input():
    if Input.is_action_just_pressed("pick"):
        on_pick()
    if Input.is_action_just_pressed("reel"):
        on_reel()

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
    OneShot,
}

const ACTION_STATE = {
    ActionState.Default: 'default',
    ActionState.Lift: 'lift',
    ActionState.FishingWait: 'fishing_wait',
    ActionState.FishingHooked: 'fishing_hooked',
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
    FishingRoll
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
}

var current_action_state: ActionState = ActionState.Default

var current_face_direction: FaceDirection = FaceDirection.Forward

var current_movement_state: MovementState = MovementState.Idle

func movement():
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
    hoe_target.emit()

signal watering_target

func emit_watering_target():
    watering_target.emit()

signal sickle_target

func emit_sickle_target():
    sickle_target.emit()

#endregion

#endregion

#region fellable_tree

signal axe_target

func emit_axe_target():
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
    if pickable_list.is_empty():
        return
    var pick := pickable_list[0]
    animation_state.start_one_shot(OneShotState.Collect)
    var result = add_inventort(pick.inventory, pick.count)
    if result:
        pick.queue_free()

func add_inventort(inventory: Inventory, count: int):
    var current: InventoryNode

    if !inventory['stack']:
        current = find_can_use_item()
        if current == null:
            pass
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
                pass
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
var is_fishing: bool = false

var is_hooked: bool = false

func enter_fishing():
    is_fishing = true
    is_hooked = false

func on_reel():
    if is_fishing:
        if is_hooked:
            on_fish()
        else:
            on_no_fish()

func on_fish():
    pass

func on_no_fish():
    await animation_state.start_one_shot(OneShotState.FishingRoll)
    await animation_state.start_one_shot(OneShotState.FishingCaptureNoFish)
    exit_fishing()

func exit_fishing():
    is_fishing = false
    is_hooked = false

#endregion
