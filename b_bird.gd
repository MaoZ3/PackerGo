extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
var target_fruit: Node2D = null
@export var speed: float = 100

func _ready():
	sprite.play("fly")  # Asegúrate de tener una animación de vuelo
	find_closest_fruit()

func find_closest_fruit():
	# Encuentra la fruta más cercana en el árbol que aún no ha sido recolectada
	var fruits = get_tree().get_nodes_in_group("fruits")
	if fruits.size() == 0:
		queue_free()  # Si no hay frutas, se elimina el ave
		return

	# Busca la fruta más cercana
	target_fruit = fruits[0]
	for fruit in fruits:
		if position.distance_to(fruit.position) < position.distance_to(target_fruit.position):
			target_fruit = fruit

func _process(delta):
	if target_fruit and target_fruit.is_inside_tree():
		# Calcula la dirección hacia la fruta más cercana
		var direction = (target_fruit.position - position).normalized()
		position += direction * speed * delta
	else:
		find_closest_fruit()  # Si no hay objetivo, busca otra fruta

func _on_area_body_entered(body):
	if body.name == "Projectile":  # Suponiendo que los proyectiles se llaman así
		queue_free()  # Destruye el ave al ser golpeada
		body.queue_free()  # También elimina el proyectil
