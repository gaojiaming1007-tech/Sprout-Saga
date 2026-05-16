extends Node

## 动作音效，一次性
@export var audio_List: Array[AudioStream]

enum AudioType {
    Footsteps_Grass,
    Chest_Open,
    Chest_Closed,
    Axe,
    Hoe,
    Watering,
    Sickle,
    FishingCasting,
    Dialogue_Start,
    UI_Click
}

enum AudioGrade {
    None,
    Footsteps,
    Chest,
    UI
}

@export var pool_size: int = 10

@export var pool: Array[AudioStreamPlayer] = []

var grade_dic: Dictionary = {}

var back_audio_player: AudioStreamPlayer

## { audio:AudioStream,volume:float } Game.LevelType
@export var back_level_audio_list: Array[Dictionary] = []

var tween: Tween

func _enter_tree() -> void:
    fill_pool()

func fill_pool():
    back_audio_player = AudioStreamPlayer.new()
    add_child(back_audio_player)
    for i in pool_size:
        var player = AudioStreamPlayer.new()
        add_child(player)
        pool.append(player)

func player_audio(audio_tpye: AudioType, volume: float = 0.0, from: float = 0.0, grade: AudioGrade = AudioGrade.None):
    if grade != AudioGrade.None:
        stop_grade(grade)
    var player: AudioStreamPlayer = get_free_player()
    player.stream = audio_List[audio_tpye]
    player.volume_db = volume
    player.play(from)

    if grade != AudioGrade.None:
        if grade_dic.has(grade):
            grade_dic[grade].push_back(player)
        else:
            grade_dic[grade] = []
            grade_dic[grade].push_back(player)

func stop_grade(grade: AudioGrade):
     if grade_dic.has(grade):
        for player in grade_dic[grade]:
            player.stop()
        grade_dic[grade] = []

func get_free_player():
    for player in pool:
        if !player.playing:
            return player
    var new_player = AudioStreamPlayer.new()
    add_child(new_player)
    pool.append(new_player)
    return new_player

func play_level_audio(level: Game.LevelType):
    if back_level_audio_list[level].size() == 0: return
    
    var current = back_level_audio_list[level]
    if tween:
        tween.kill()

    if back_audio_player.playing:
        tween = create_tween().set_parallel(true)
        tween.tween_property(back_audio_player, "volume_db", -80, 1)
        await tween.finished
        back_audio_player.stop()

    back_audio_player.volume_db = -80
    back_audio_player.stream = current["audio"]
    back_audio_player.play()
    tween = create_tween().set_parallel(true)
    tween.tween_property(back_audio_player, "volume_db", current["volume"], 1)

func stop_level_audio():
    back_audio_player.stop()
