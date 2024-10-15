extends Area2D

@onready var rango = $Rango
@onready var palanca = $Palanca
@onready var Radio = $CollisionShape2D.shape.radius
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func  _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		pass
	
