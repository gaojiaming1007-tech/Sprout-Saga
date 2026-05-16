class_name QuantitySelection

extends CanvasLayer

signal finish(current: int)

func _ready() -> void:
    var gp = %Root.get_global_mouse_position()
    %Root.position = Vector2(gp.x - %Root.size.x, gp.y - %Root.size.y)

func _on_value_changed(value: float) -> void:
    %Count.text = str(int(value))
 
func set_default(min_value: int, max_value: int, value: int):
    %Slider.min_value = min_value
    %Slider.max_value = max_value
    %Slider.value = value
    _on_value_changed(value)


func _on_sub_pressed() -> void:
    %Slider.value = max(%Slider.min_value, %Slider.value - 1)


func _on_add_pressed() -> void:
    %Slider.value = min(%Slider.max_value, %Slider.value + 1)


func _on_cancel_pressed() -> void:
    UtilsManager.is_quantity_selection = false
    queue_free()

func _on_sure_pressed() -> void:
    finish.emit(int(%Slider.value))
