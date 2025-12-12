@tool
class_name GraphicalMeshHandler extends Node3D

@onready var planet_mesh := $PlanetGraphicsMesh as GraphicalMesh
@onready var grid_mesh := $GridGraphicsMesh as GraphicalMesh



func initialise_graphics(mesh:GeometryMesh,material:Material):
	planet_mesh.initialise(mesh)
	planet_mesh.create_mesh()
	planet_mesh.mesh.surface_set_material(0,material)


func initialise_grid(mesh:GeometryMesh,material:Material):
	grid_mesh.initialise(mesh)
	grid_mesh.create_mesh()
	grid_mesh.mesh.surface_set_material(0,material)


func update_graphics(mesh:GeometryMesh,new_colours:PackedColorArray):
	planet_mesh.update_vertex_colours(new_colours)
	var arrays:Array = planet_mesh.mesh.surface_get_arrays(0)
	planet_mesh.update_mesh_attributes(arrays[Mesh.ARRAY_VERTEX],arrays[Mesh.ARRAY_INDEX],arrays[Mesh.ARRAY_NORMAL])
