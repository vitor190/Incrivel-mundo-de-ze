## gerenciador_missoes.gd
extends Node

signal missoes_atualizadas

var cena_atual: String = "quarto"

func set_cena(nome: String):
	cena_atual = nome
	emit_signal("missoes_atualizadas")

func concluir_missao(id: String):
	if not DadosMissoes.missoes.has(id):
		return
	DadosMissoes.missoes[id]["concluida"] = true
	emit_signal("missoes_atualizadas")
	print("Missão concluída: ", id)

func concluir_sub_missao(missao_id: String, sub_id: String):
	if not DadosMissoes.missoes.has(missao_id):
		return
	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])
	for sub in subs:
		if sub["id"] == sub_id:
			sub["concluida"] = true
			print("Sub-missão concluída: ", sub_id)
			if _todas_sub_finalizadas(missao_id):
				concluir_missao(missao_id)
			else:
				emit_signal("missoes_atualizadas")
			return

func falhar_sub_missao(missao_id: String, sub_id: String):
	if not DadosMissoes.missoes.has(missao_id):
		return
	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])
	for sub in subs:
		if sub["id"] == sub_id:
			sub["falhou"] = true
			print("Sub-missão falhada: ", sub_id)
			if _todas_sub_finalizadas(missao_id):
				concluir_missao(missao_id)
			else:
				emit_signal("missoes_atualizadas")
			return

func _todas_sub_concluidas(missao_id: String) -> bool:
	var subs = DadosMissoes.missoes[missao_id].get("sub_missoes", [])
	for sub in subs:
		if not sub.get("concluida", false):
			return false
	return true

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
		if not m["concluida"]:
			var entry = m.duplicate(true)
			entry["id"] = id
			resultado.append(entry)
	return resultado