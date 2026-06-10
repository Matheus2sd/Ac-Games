# Arquivo: killzone.gd

extends Area2D

# Ao ser criado na tela, o sinal body_entered (sinal emitido automaticamente 
# quando um corpo físico entra na área do nó Area2D) é conectado à função 
# on_body_entered
func _ready():
	body_entered.connect(_on_body_entered)

# Toda vez que um corpo entra na Area2D, a função _on_body_entered recebe
# automaticamente como parâmetro o nó que entrou nessa área, representado
# pelo body
func _on_body_entered(body):
		# verifica se o nó que entrou na área tem o método die()
	if body.has_method("die"):
			# chama a função die() desse nó que entrou na área
		body.die()
