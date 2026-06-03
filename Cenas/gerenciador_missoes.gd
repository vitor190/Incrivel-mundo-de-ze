extends Node

signal missoes_atualizadas

var cena_atual: String = "quarto"


func set_cena(nome: String) -> void:
	cena_atual = nome
	missoes_atualizadas.emit()


func concluir_missao(id: String) -> void:
	if not DadosMissoes.missoes.has(id):
		return

	if DadosMissoes.missoes[id].get("concluida", false):
		return

	DadosMissoes.missoes[id]["concluida"] = true
	missoes_atualizadas.emit()
	print("Missão concluída: ", id)


func concluir_sub_missao(missao_id: String, sub_id: String) -> void:
	if not DadosMissoes.missoes.has(missao_id):
		return

	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])

	for sub in subs:
		if sub["id"] == sub_id:
			if sub.get("concluida", false):
				return

			sub["concluida"] = true
			print("Sub-missão concluída: ", sub_id)

			if _todas_sub_finalizadas(missao_id):
				concluir_missao(missao_id)
			else:
				missoes_atualizadas.emit()

			return


func falhar_sub_missao(missao_id: String, sub_id: String) -> void:
	if not DadosMissoes.missoes.has(missao_id):
		return

	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])

	for sub in subs:
		if sub["id"] == sub_id:
			if sub.get("falhou", false):
				return

			sub["falhou"] = true
			print("Sub-missão falhada: ", sub_id)

			if _todas_sub_finalizadas(missao_id):
				concluir_missao(missao_id)
			else:
				missoes_atualizadas.emit()

			return


func _todas_sub_finalizadas(missao_id: String) -> bool:
	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])

	for sub in subs:
		if not sub.get("concluida", false) and not sub.get("falhou", false):
			return false

	return true


func pode_ir_trabalho() -> bool:
	var c = DadosMissoes.missoes.get("unifor_bloco_c", {})
	var d = DadosMissoes.missoes.get("unifor_bloco_d", {})

	return c.get("concluida", false) and d.get("concluida", false)


func get_missoes_ativas() -> Array:
	var ids = DadosMissoes.missoes_por_cena.get(cena_atual, [])
	var resultado = []

	for id in ids:
		var m = DadosMissoes.missoes[id]

		if not m.get("concluida", false):
			var entry = m.duplicate(true)
			entry["id"] = id
			resultado.append(entry)

	return resultado
