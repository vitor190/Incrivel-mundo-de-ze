extends Node2D
class_name TransparentRoof

const SHADER := preload("res://Cenas/roof_transparency.gdshader")

@export var roof_layers: Array[CanvasItem] = []
@export var detection_area: Area2D
@export_range(0.0, 1000.0, 1.0) var radius: float = 90.0
@export_range(0.0, 500.0, 1.0) var softness: float = 50.0
@export_range(0.0, 1.0, 0.01) var min_alpha: float = 0.35
@export_range(0.0, 2.0, 0.05) var fade_duration: float = 0.25

# Reservado para a etapa "porta abre teto": Node2D do interior do prédio,
# inicialmente invisível. Ainda não consumido — gancho pra próxima fase.
@export var interior_root: Node2D

# Nome de uma Custom Data Layer (tipo bool) no TileSet. Tiles com esse
# valor true ficam opacos. Vazio = ignora custom data e usa só colisão.
@export var opaque_custom_data: String = ""

var _player: Node2D
var _materials: Array[ShaderMaterial] = []
var _strength_tween: Tween
var _effect_strength: float = 0.0

func _ready() -> void:
	_setup_materials()
	_player = get_tree().get_first_node_in_group("player")
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _setup_materials() -> void:
	_materials.clear()
	for layer in roof_layers:
		if layer == null:
			continue
		var mat := ShaderMaterial.new()
		mat.shader = SHADER
		mat.set_shader_parameter("radius", radius)
		mat.set_shader_parameter("softness", softness)
		mat.set_shader_parameter("min_alpha", min_alpha)
		mat.set_shader_parameter("effect_strength", 0.0)
		_apply_collision_mask(layer, mat)
		layer.material = mat
		_materials.append(mat)

func _apply_collision_mask(layer: CanvasItem, mat: ShaderMaterial) -> void:
	if not (layer is TileMapLayer):
		mat.set_shader_parameter("use_collision_mask", false)
		return
	var tml: TileMapLayer = layer
	var ts: TileSet = tml.tile_set
	if ts == null:
		mat.set_shader_parameter("use_collision_mask", false)
		return
	var used: Rect2i = tml.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		mat.set_shader_parameter("use_collision_mask", false)
		return
	var img := Image.create(used.size.x, used.size.y, false, Image.FORMAT_R8)
	for cell: Vector2i in tml.get_used_cells():
		var td: TileData = tml.get_cell_tile_data(cell)
		if td == null:
			continue
		var stay_opaque := false
		if opaque_custom_data != "":
			var v: Variant = td.get_custom_data(opaque_custom_data)
			if typeof(v) == TYPE_BOOL and v:
				stay_opaque = true
		if not stay_opaque:
			for layer_idx in range(ts.get_physics_layers_count()):
				if td.get_collision_polygons_count(layer_idx) > 0:
					stay_opaque = true
					break
		if stay_opaque:
			img.set_pixel(cell.x - used.position.x, cell.y - used.position.y, Color(1, 0, 0))
	var tex := ImageTexture.create_from_image(img)
	mat.set_shader_parameter("use_collision_mask", true)
	mat.set_shader_parameter("collision_mask", tex)
	mat.set_shader_parameter("mask_origin_tiles", Vector2(used.position))
	mat.set_shader_parameter("mask_size_tiles", Vector2(used.size))
	mat.set_shader_parameter("tile_size_local", Vector2(ts.tile_size))

func _process(_delta: float) -> void:
	if _player == null or _materials.is_empty():
		return
	var pos := _player.global_position
	for mat in _materials:
		mat.set_shader_parameter("player_position", pos)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_set_effect(1.0)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_set_effect(0.0)

func _set_effect(target: float) -> void:
	if _strength_tween and _strength_tween.is_valid():
		_strength_tween.kill()
	_strength_tween = create_tween()
	_strength_tween.tween_method(_apply_strength, _effect_strength, target, fade_duration)

func _apply_strength(v: float) -> void:
	_effect_strength = v
	for mat in _materials:
		mat.set_shader_parameter("effect_strength", v)
