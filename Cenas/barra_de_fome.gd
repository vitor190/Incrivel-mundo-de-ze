extends Node2D

@onready var progress_bar = $CanvasLayer/ProgressBar

func _ready():
	# Procura o Player no grupo e se conecta ao sinal dele automaticamente
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.fome_alterada.connect(_on_player_fome_alterada)

func _on_player_fome_alterada(novo_valor):
	if progress_bar:
		progress_bar.value = novo_valor
