# Incrível Mundo de Zé

Um jogo 2D de exploração desenvolvido em Godot Engine como projeto da disciplina de Computação Gráfica da UNIFOR (Universidade de Fortaleza).

## Sobre o jogo

O jogo acompanha a rotina de José, um estudante universitário que também trabalha no Banco do Nordeste. Durante um dia completo, o jogador guia José desde o momento em que acorda, passando pela UNIFOR, até o expediente no banco — cada etapa com suas próprias tarefas e desafios.

A inspiração veio de jogos como Stardew Valley, com foco na exploração tranquila e na progressão através de minigames simples.

## Fluxo do jogo

1. Quarto — José acorda e se prepara para o dia
2. UNIFOR — explora o campus e frequenta as aulas nos Blocos C e D
3. Banco do Nordeste — cumpre o expediente com tarefas do trabalho
4. Retorno para casa — fim do dia, resultado baseado no XP acumulado

## Funcionalidades

- Personagem jogável com animações de movimento
- Mapa do campus da UNIFOR com minimapa
- Sistema de missões — orienta o jogador durante toda a jornada
- Minigames nos blocos da UNIFOR e no Banco do Nordeste
- Barra de experiência (XP) que determina o resultado do dia
- Trilha sonora original em loop
- Transições entre cenas com animação de ônibus
- Sistema de fome do personagem
- Ambientação de mundo, como carros e personagens não jogaveis

## Tecnologias

- [Godot Engine 4](https://godotengine.org/)
- GDScript

## Como rodar

1. Clone o repositório:
```bash
git clone https://github.com/vitor190/Incrivel-mundo-de-ze.git
```
2. Abra o Godot Engine
3. Importe a pasta do projeto
4. Rode com F5

## Estrutura do projeto

```
res://
 ├── Cenas/       # Todas as cenas do jogo
 │    ├── campus  # Mapa principal da UNIFOR
 │    ├── quarto  # Cena inicial
 │    ├── bloco C e D  # Salas de aula
 │    └── banco   # Banco do Nordeste
 ├── assets/      # Sprites, sons e recursos visuais
 └── project.godot
```

## Equipe
- Renan Elid
- Vitor César
- Lucas Braide
- Lucas Raposo
- Mateuz Tomás

  
Desenvolvido por alunos do curso de Ciência da Computação da UNIFOR como trabalho da disciplina de Computação Gráfica.
