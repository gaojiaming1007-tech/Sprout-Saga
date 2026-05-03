class_name TimeRecord

extends Node2D

signal new_day

signal new_year

signal time_update

signal day

signal night

enum Season {
    Spring,
    Summer,
    Fall,
    Winter
}

const SEASON = {
    Season.Spring: 'spring',
    Season.Summer: 'summer',
    Season.Fall: 'fall',
    Season.Winter: 'winter',
}

const MONTH_DAYS = {
    1: 31,
    2: 29,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31
}

const SEASONS = {
    12: Season.Winter,
    1: Season.Winter,
    2: Season.Winter,
    3: Season.Spring,
    4: Season.Spring,
    5: Season.Spring,
    6: Season.Summer,
    7: Season.Summer,
    8: Season.Summer,
    9: Season.Fall,
    10: Season.Fall,
    11: Season.Fall
}

@export var date: Label

@export var time: Label

@export var pointer: TextureRect

func _enter_tree() -> void:
    GameManager.game.level_loaded.connect(handle_time)

func _ready() -> void:
    update_pointer_rotation()
    handle_time()

func handle_time():
    var resource = GameManager.game.game_resource
    if resource.hour == 6 && resource.minute == 0:
        day.emit()
    elif resource.hour == 21 && resource.minute == 0:
        night.emit()

func _on_timer_update() -> void:
    var resource = GameManager.game.game_resource
    resource.minute += 1

    if resource.minute >= 60:
        resource.minute = 0
        resource.hour += 1

        if resource.hour >= 24:
            resource.hour = 0
            resource.day += 1
            new_day.emit()

            if resource.month == 12 && resource.day > MONTH_DAYS[12]:
                reset_to_january_first()
            elif resource.day > MONTH_DAYS[resource.month]:
                resource.day = 1
                resource.month += 1

    if SEASONS[resource.month] != resource.season:
        resource.season = SEASONS[resource.month]
        # GameManager.game.switch_season(resource.season)
    
    update_pointer_rotation()

func update_pointer_rotation():
    var resource = GameManager.game.game_resource
    pointer.rotation_degrees = (float(resource.hour) + float(resource.minute) / 60.0 - 12) * 15.0

    date.text = "%s月%s日" % [resource.month, resource.day]

    var hour_str = "0" + str(resource.hour) if resource.hour < 10 else str(resource.hour)
    var minute_str = "0" + str(resource.minute) if resource.minute < 10 else str(resource.minute)

    time.text = "%s:%s" % [hour_str, minute_str]

    if resource.hour == 6 && resource.minute == 0:
        day.emit()
    elif resource.hour == 21 && resource.minute == 0:
        night.emit()

    time_update.emit()

func reset_to_january_first():
    var resource = GameManager.game.game_resource
    resource.month = 1
    resource.day = 1
    resource.hour = 0
    resource.minute = 0
    resource.season = Season.Winter
    new_year.emit()
