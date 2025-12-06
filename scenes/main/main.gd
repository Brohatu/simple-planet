extends Node3D


@export var rebuild:bool:
	set(val):
		if val:
			$Planet.build()
			val = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Planet.build()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
