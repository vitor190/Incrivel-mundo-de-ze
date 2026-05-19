## transicao.gd
## Attach this to a CanvasLayer node called "Transicao"
## This node must be in your main scene (campus.tscn)
 
extends CanvasLayer
 
@onready var overlay = $ColorRect
@onready var tween: Tween
 
func _ready():
	overlay.color = Color(0, 0, 0, 0)  # começa transparente
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
 
func ir_para_cena(caminho_cena: String):
	# Bloqueia input durante a transiçãoa
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
 
	# Fade in (escurece)
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.6)
	await tween.finished
 
	# Troca de cena
	get_tree().change_scene_to_file(caminho_cena)
