class_name FellableTreeResource

extends Resource

## 完整的树木 受击动画
@export var whole_atlas: AtlasTexture

## 木桩
@export var stump_atlas: AtlasTexture

## 倒塌的树木残端
@export var collapse_altas: AtlasTexture

## 变成木桩需要砍伐的次数
@export var times: int

## 变成木桩再次砍伐消失需要的次数
@export var destroy_times: int

## 砍伐掉落的木头
@export var wood: Inventory
