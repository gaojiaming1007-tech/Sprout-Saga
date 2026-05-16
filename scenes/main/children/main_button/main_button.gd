class_name MainButton

extends Button


func _on_pressed() -> void:
    SoundManager.player_audio(SoundManager.AudioType.UI_Click, -3, 0.01, SoundManager.AudioGrade.UI)
