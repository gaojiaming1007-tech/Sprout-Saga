class_name TaskItem

extends InterfaceNode

var current: TaskResource

var task: Task

@export var done_icon: AtlasTexture

@export var undone_icon: AtlasTexture

func _ready() -> void:
    %Summary.text = current.summary
    update_state()

func on_left_click():
    super.on_left_click()
    task.on_click_task_item(current)

func update_state():
    %State.texture = done_icon if current.done else undone_icon
