@tool
class_name GraphicalMeshHandler extends Node3D

@onready var planet_mesh := $PlanetGraphicsMesh as GraphicalMesh
@onready var grid_mesh := $GridGraphicsMesh as GraphicalMesh


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func initialise_graphics(geometry_handler:GeometryMeshHandler,data:PlanetData):
	planet_mesh.initialise(geometry_handler.planet_mesh)
	planet_mesh.create_mesh()
	planet_mesh.mesh.surface_set_material(0,data.surface_graphics_material)
