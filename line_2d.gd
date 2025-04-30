extends Line2D

@export var num_points: int = 100          # Número de puntos de la espiral
@export var spiral_scale: float = 10.0     # Escala inicial (tamaño de la espiral)
@export var angle_increment: float = 0.1  # Incremento angular (suavidad de la espiral)

func _ready():
	draw_spiral()

func draw_spiral():
	# Constante de la proporción áurea
	var b = 0.306349
	
	# Limpiar los puntos actuales
	clear_points()
	
	# Centro de la espiral (posición base del nodo Line2D)
	var center = global_position
	
	# Generar los puntos de la espiral
	for i in range(num_points):
		var theta = i * angle_increment
		var r = spiral_scale * exp(b * theta)
		var x = r * cos(theta) + center.x
		var y = r * sin(theta) + center.y
		add_point(Vector2(x, y))
