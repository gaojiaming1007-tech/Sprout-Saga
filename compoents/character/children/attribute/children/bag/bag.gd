class_name Bag

extends InterfaceNode

var bag_item_list: Array[BagItem] = []

var tween: Tween

func _enter_tree() -> void:
    for child in %ListContainer.get_children():
        if child is BagItem:
            child.bag = self
            bag_item_list.append(child)
    reset()

func _process(delta):
    if Input.is_action_just_pressed("bag_switch"):
        switch()

func switch():
    if tween:
        tween.kill()
    tween = create_tween().set_parallel(true)
    if !visible:
        visible = true
        tween.tween_property(self , "modulate:a", 1.0, 0.1)
    else:
        tween.tween_property(self , "modulate:a", 0.0, 0.1)
        tween.finished.connect(func(): visible = false)

func reset():
    if tween:
        tween.kill()
    visible = false
    modulate.a = 0.0
