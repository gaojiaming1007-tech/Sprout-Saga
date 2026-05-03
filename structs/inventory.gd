class_name Inventory

extends Resource

enum InventoryType {
    ###武器
    Weapon,
    ###防具
    Armor,
    ###材料
    Material,
    ###种子
    Seed,
    ###食物
    Food,
    ###药品
    Medicine,
    ###工具
    Tool,
    ###果实
    Crop,
    ###建筑
    Building
}

const INVENTORY_TYPE = {
    InventoryType.Weapon: '武器',
    InventoryType.Armor: '防具',
    InventoryType.Material: '材料',
    InventoryType.Seed: '种子',
    InventoryType.Food: '食物',
    InventoryType.Medicine: '药品',
    InventoryType.Tool: '工具',
    InventoryType.Crop: '果实',
    InventoryType.Building: '建筑'
}

##物品ID
@export var id: int

##物品贴图
@export var texture: AtlasTexture

##高亮贴图
@export var highlight_texture: AtlasTexture

##物品名称
@export var name: String

##物品描述
@export var description: String

##物品类型
@export var type: InventoryType

##物品价格
@export var price: int

###物品是否可以堆叠
@export var stack: bool

###物品是否可举起
@export var lift: bool
