class_name PauseMenu

extends CanvasLayer

func _enter_tree() -> void:
    visible = false

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        if visible:
            _on_continue_pressed()
        else:
            on_click_pause()

func on_click_pause():
    visible = true
    GameManager.pause()

func _on_continue_pressed() -> void:
    visible = false
    GameManager.resume()

func _on_main_pressed() -> void:
    _on_continue_pressed()
    SoundManager.stop_level_audio()
    GameManager.quit.emit()
    GameManager.save_to_archives()
    LoadingManager.enter(UtilsManager.get_screen_position(GameManager.game.character.graphics).position, false,
        func():
            SceneManager.switch_scene(SceneManager.Scene.Main)
            await SceneManager.scene_changed
            LoadingManager.leave(Vector2(0.5, 0.5))
)
