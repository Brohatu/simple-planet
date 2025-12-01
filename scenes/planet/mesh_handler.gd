@tool
class_name MeshHandler extends Node3D


@onready var planet_mesh := $PlanetMesh as GeometryMesh
@onready var planet := $".." as Planet
@onready var planet_data := planet.data

@onready var graphics_mesh := $GraphicalMesh as GraphicalMesh


#region Abstract Methods
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#endregion


func build_planet_mesh():
	#var start_time = Time.get_ticks_usec()
	# Planet geometry mesh
	generate_planet_shape()
	generate_planet_mesh()
	var mesh_path = 'resources/meshes/' + str(planet_data.resolution)
	ResourceSaver.save(planet_mesh.mesh,mesh_path)
	# Planet graphics mesh
	
	print("Planet build time: ", (Time.get_ticks_usec() - planet.start_time)/1_000_000.0)


func generate_planet_shape():
	planet_mesh.clear()
	planet_mesh.generate_icosahedron(get_parent().data.resolution)
	print("Icosahedron done: " + str((Time.get_ticks_usec() - planet.start_time)/1_000_000.0))
	planet_mesh.tesselate_ico_mesh()
	print("Tesselation done: " + str((Time.get_ticks_usec() - planet.start_time)/1_000_000.0))
	planet_mesh.normalise()


func generate_planet_mesh():
	planet_mesh.mesh = planet_mesh.create_mesh(ArrayMesh.new())
	print("Mesh done: ", (Time.get_ticks_usec() - planet.start_time)/1_000_000.0)
	planet_mesh.mesh.surface_set_material(0,planet_data.surface_material)
