extends Node2D
"""



@export var player: NodePath  # Ruta al nodo del personaje que debe ser controlado
@onready var player_node = get_node(player)

@onready var touch_buttons = $TouchScreenButtons  # Nodo que contiene los botones táctiles

var move_direction: int = 0  # -1 (izquierda), 1 (derecha), 0 (parado)
var jump_pressed: bool = false

func _ready():
	# Ocultar botones táctiles si no es un dispositivo móvil
	if not OS.has_feature("touchscreen"):
		for button in touch_buttons.get_children():
			button.visible = false
	else:
		_connect_button_signals()

func _connect_button_signals():
	# Conectar las señales de los botones táctiles
	$TouchScreenButtons/Button_Left.connect("pressed", Callable(self, "_on_left_pressed"))
	$TouchScreenButtons/Button_Left.connect("released", Callable(self, "_on_left_released"))
	$TouchScreenButtons/Button_Right.connect("pressed", Callable(self, "_on_right_pressed"))
	$TouchScreenButtons/Button_Right.connect("released", Callable(self, "_on_right_released"))
	$TouchScreenButtons/Button_Jump.connect("pressed", Callable(self, "_on_jump_pressed"))
	$TouchScreenButtons/Button_Collect.connect("pressed", Callable(self, "_on_collect_pressed"))
	$TouchScreenButtons/Button_Throw.connect("pressed", Callable(self, "_on_throw_pressed"))

# Métodos para manejar los botones táctiles
func _on_left_pressed():
	move_direction = -1

func _on_left_released():
	if move_direction == -1:
		move_direction = 0

func _on_right_pressed():
	move_direction = 1

func _on_right_released():
	if move_direction == 1:
		move_direction = 0

func _on_jump_pressed():
	jump_pressed = true

func _on_collect_pressed():
	if player_node and player_node.has_method("collect_fruit"):
		player_node.collect_fruit()

func _on_throw_pressed():
	if player_node and player_node.has_method("throw_fruit"):
		player_node.throw_fruit()

func _process(delta: float) -> void:
	if player_node:
		# Enviar datos de movimiento y salto al personaje
		if player_node.has_method("set_movement_input"):
			player_node.set_movement_input(move_direction, jump_pressed)
		jump_pressed = false  # Restablecer el salto después de enviarlo
"""
