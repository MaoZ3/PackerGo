extends Node2D


func _ready():
	var fruit = $AnimatedSprite2D.sprite_frames.get_animation_names()

	# Generate a random number
	var random_index = randi() % fruit.size()

	# Ensure the random number is not 6
	while random_index == 6:
		random_index = randi() % fruit.size()

	# Play the animation using the generated index
	$AnimatedSprite2D.play(fruit[random_index])


"""	
func change_random_texture():
	var random_index = randi() % textures.size()
	var random_texture = textures[random_index]

	# Crear un nuevo nodo Sprite2D
	var new_fruit = Sprite2D.new()
	new_fruit.texture = random_texture
	add_child(new_fruit)


# Calcular la posición x para el nuevo nodo
	var num_children = get_child_count()
	var new_fruit_width = new_fruit.texture.get_width()
	var initial_x_position = -num_children * new_fruit_width
	new_fruit.position.x = initial_x_position

	if num_children > 0:
		var last_child = get_child(num_children - 1)
		new_fruit.position.x = last_child.position.x + new_fruit_width
	else:
		new_fruit.position.x = -new_fruit_width"""


"""extends Node2D

var velocity = 100
var textures = [
	preload("res://mznR.png"),
	preload("res://MznV.png"),
	preload("res://PeraV.png")
]

@onready var path2d: Path2D = $Path2D
var new_fruit: Sprite2D
var tween: Tween

func _ready():
	change_random_texture()
	start_animation()

func change_random_texture():
	var random_index = randi() % textures.size()
	var random_texture = textures[random_index]

	new_fruit = Sprite2D.new()
	new_fruit.texture = random_texture

	var new_fruit_width = new_fruit.texture.get_width()
	new_fruit.position.x = -new_fruit_width

	# Agregar el Tween como recurso al nodo
	tween = Tween.new()
	add_child(tween)

	var duration = 5.0
	tween.interpolate_property(new_fruit, "position", new_fruit.position, path2d.curve.get_point_position(path2d.curve.get_point_count() - 1), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()"""


"""
	# Conectar la señal "tween_completed" del Tween a "_on_tween_completed"
	tween.connect("tween_completed", self, "_on_tween_completed")

	add_child(new_fruit)

func start_animation():
	# No es necesario iniciar el Tween aquí, ya que se inicia en change_random_texture()
	pass

func _on_tween_completed():
	# Manejar el evento de finalización de la animación
	new_fruit.queue_free()

func _process(delta):
	# No es necesario eliminar manualmente las frutas en _process, ya que se maneja en la animación Tween
	pass"""



#Este codigo funciona pero no es el efecto deceado 
"""extends Node2D

var velocity = 100 

var textures = [
	preload("res://mznR.png"),
	preload("res://MznV.png"),
	preload("res://PeraV.png")
]



func _ready(): 
	change_random_texture()
	
func change_random_texture():
	var random_index = randi() % textures.size() 
	var random_texture = textures[random_index]
	
	var new_fruit = Sprite2D.new()
	new_fruit.texture = random_texture
	
	
	var num_children = get_child_count()
	var initial_x_position = -num_children * new_fruit.texture.get_width()
	new_fruit.position.x = initial_x_position
	
	if num_children > 0:
		var last_child = get_child(num_children - 1)
		var new_fruit_width = new_fruit.texture.get_width()
		new_fruit.position.x = last_child.position.x + new_fruit_width
		
	else:
		new_fruit.position.x = -new_fruit.texture.get_width()
	
	add_child(new_fruit)
	
	
	#if $MznV != null:
	#	$MznV.queue_free()
		
	#$MznV.texture = random_texture
	
	var new_texture_instance = Sprite2D.new()
	new_texture_instance.texture = random_texture
	add_child(new_texture_instance)
	
	
func _process(delta):
	change_random_texture()
	
	
	for child in get_children():
		child.position.x += velocity * delta
		if child.position.x > get_viewport_rect().size.x:
			child.queue_free()
		
		
func _physics_process(delta):
	var current_position = position
	var new_position = current_position + Vector2(velocity * delta, 0)
	position = new_position """ 


	
	
