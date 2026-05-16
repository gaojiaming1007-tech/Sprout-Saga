class_name HoldEffectResource

extends Resource

var false_color = Color(0.8, 0.2, 0.2, 0.0)

var true_color = Color(1.0, 1.0, 1.0, 0.8)

## 返回交互范围 ( 半径 比如输入1 就是3*3的范围 2 * input + 1 )
func get_range():
    return 1

## 实时更新可交互范围
func update_texture_limit():
    var last_count = get_range()
    var character = GameManager.game.character
    var count = last_count * 2 + 1
    var image = Image.create(count, count, false, Image.FORMAT_RGBA8)

    var colors = []

    var range_result: Array[bool] = []

    for y in range(-last_count, last_count + 1):
        for x in range(-last_count, last_count + 1):
            var p = character.global_position + Vector2(x * 16, y * 16)
            if (abs(y) + abs(x) > last_count && !has_oblique_angle()) || (x == 0 && y == 0 && !has_origin()):
                colors.push_back(false_color)
                range_result.push_back(false)
            else:
                var result = get_cell_limit(p)
                colors.push_back(true_color if result else false_color)
                range_result.push_back(result)
    
    for y in range(count):
        for x in range(count):
            var index = y * count + x
            var color = colors[index]
            image.set_pixel(x, y, color)
    
    return [range_result, ImageTexture.create_from_image(image)]

## 在鼠标点击可交互范围触发
func play_effect(at_position: Vector2):
    pass

## 根据位置判断是否可交互
func get_cell_limit(at_position: Vector2):
    pass

## 斜角的方块是否可以进行逻辑判断（不需要才去重写 返回false即可）
func has_oblique_angle():
    return true

## 是否需要判断玩家站立位置
func has_origin():
    return true