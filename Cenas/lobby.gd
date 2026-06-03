extends Control


func _on_iiniciar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/quarto.tscn")


func _on_creditos_btn_pressed() -> void:
	pass # Replace with function body.


func _on_sair_btn_pressed() -> void:
	get_tree().quit()
