class_name Task

extends InterfaceNode

@export var task_list_resource: TaskListResource

var task_list: Array[TaskItem] = []

var tween: Tween

var current_select: TaskResource = null

enum TaskState {
    ## 为接取任务
    Un_Get,
    ## 未完成
    Un_Done,
    ## 已完成为交接
    Done,
    ## 已完成并且交接
    Finish
}

func _enter_tree() -> void:
    reset()

func _ready() -> void:
    draw_list()
    GameManager.quit.connect(save)

func save():
    for task in task_list_resource.list:
        if task.detail is CollectTaskDetailResource:
            ResourceSaver.save(task, task.resource_path)
    ResourceSaver.save(task_list_resource, task_list_resource.resource_path)

func draw_list():
    for e in task_list:
        e.queue_free()
    task_list.clear()
    for e in task_list:
        e.queue_free()
    task_list.clear()
    for task in task_list_resource.list:
        var item: TaskItem = ResourceManager.load_resource("res://compoents/character/children/attribute/children/task/children/task_item/task_item.tscn").instantiate()
        item.current = task
        item.task = self
        %TaskContainer.add_child(item)
        task_list.push_back(item)

func switch():
    if tween:
        tween.kill()
    tween = create_tween().set_parallel(true)
    if !visible:
        visible = true
        %Detail.visible = false
        tween.tween_property(self , "modulate:a", 1.0, 0.1)
    else:
        tween.tween_property(self , "modulate:a", 0.0, 0.1)
        tween.finished.connect(func(): visible = false)

func reset():
    if tween:
        tween.kill()
    visible = false
    modulate.a = 0.0
    %Detail.visible = false

func on_click_task_item(task: TaskResource):
    if current_select != task:
        SoundManager.player_audio(SoundManager.AudioType.UI_Click, -3, 0.01, SoundManager.AudioGrade.UI)
        current_select = task
        %Detail.visible = true
        for child in %CollectContainer.get_children():
            child.queue_free()
        %Describe.text = task.describe
        if task.detail is CollectTaskDetailResource:
            for t in task.detail.list:
                var item: CollectItem = ResourceManager.load_resource("res://compoents/character/children/attribute/children/task/children/collect_item/collect_item.tscn").instantiate()
                item.current = t
                %CollectContainer.add_child(item)
        %Detail.reset_size()

## 是否以及完成过任务
func over_task_from_id(id: int):
    return task_list_resource.over_list.has(id)

func get_task_from_id(id: int):
    for task in task_list_resource.list:
        if task.id == id:
            return task
    return null

func get_task_state(id: int):
    if over_task_from_id(id):
        return TaskState.Finish
    var task: TaskResource = get_task_from_id(id)
    if task:
        return TaskState.Done if task.done else TaskState.Un_Done
    return TaskState.Un_Get

func to_add_task(id: int):
    var task: TaskResource = ResourceManager.load_resource("res://resources/task/1.tres")
    task_list_resource.list.push_back(task)
    draw_list()

func refresh_task_state(npc: String):
    for i in range(task_list_resource.list.size()):
        var task := task_list_resource.list[i]
        if task.is_own_npc(npc):
            task.deal_done(npc)
            task_list[i].update_state()

func to_over_task(id: int):
    var task: TaskResource = get_task_from_id(id)
    task.pay()
    task_list_resource.list = task_list_resource.list.filter(func(c): return c != task)
    task_list_resource.over_list.push_back(id)
    draw_list()
    ## 任务奖励
    PromptManager.start_celebrate("任务完成：%s" % [task.summary], task.reward)
