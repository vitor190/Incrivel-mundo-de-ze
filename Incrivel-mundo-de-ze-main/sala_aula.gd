## sala_aula.gd
## Attach this to the root node of sala_aula.tscn
## Cena temporária — fundo preto com texto de confirmação
## Substitua quando a cena real da sala for criada
 
extends Node2D
 
func _ready():
	# Volta para o campus ao apertar qualquer tecla (para testar)
	pass
 
func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Cenas/sala_bloco_c.tscn")
 
