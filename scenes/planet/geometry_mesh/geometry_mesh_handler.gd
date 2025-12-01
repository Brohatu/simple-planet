@tool
class_name GeometryMeshHandler extends Node3D
#
#
@onready var planet_mesh := $GeometryMesh as GeometryMesh
var grid_mesh:GeometryMesh
#@onready var planet := $".." as Planet
#@onready var planet_data := planet.data
#

#
#
#region Abstract Methods
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#pass
#
#endregion


func initialise_planet_meshes():
	var start_time = Time.get_ticks_usec()
	# Planet geometry mesh
	planet_mesh.clear()
	planet_mesh.generate_icosahedron(get_parent().data.resolution)
	planet_mesh.tesselate_ico_mesh()
	
	planet_mesh.mesh = planet_mesh.create_mesh(ArrayMesh.new())
	print("Mesh done: ", (Time.get_ticks_usec() - start_time)/1_000_000.0)
	
	
	
	
	
	
#func do_rebuild():
	#var mdt = MeshDataTool.new()
	#mdt.create_from_surface(planet_mesh.mesh,0)
	#var v_size = mdt.get_vertex_count()
	#for vi in v_size:
		#var v = mdt.get_vertex(vi)
		#v *= 1.5
		#mdt.set_vertex(vi,v)
	#planet_mesh.mesh.clear_surfaces()
	#mdt.commit_to_surface(planet_mesh.mesh)
#
#
#func build_planet_mesh():
	##var start_time = Time.get_ticks_usec()
	## Planet geometry mesh
	#generate_planet_shape()
	#generate_planet_mesh()
	#var mesh_path = 'resources/meshes/' + str(planet_data.resolution)
	#ResourceSaver.save(planet_mesh.mesh,mesh_path)
	## Planet graphics mesh
	#
	#print("Planet build time: ", (Time.get_ticks_usec() - planet.start_time)/1_000_000.0)
#
#
#func build_graphics_mesh():
	#pass
#
#func generate_planet_shape():
	#planet_mesh.clear()
	#planet_mesh.generate_icosahedron(get_parent().data.resolution)
	#print("Icosahedron done: " + str((Time.get_ticks_usec() - planet.start_time)/1_000_000.0))
	#planet_mesh.tesselate_ico_mesh()
	#print("Tesselation done: " + str((Time.get_ticks_usec() - planet.start_time)/1_000_000.0))
	#planet_mesh.normalise()
#
#
#func generate_planet_mesh():
	#planet_mesh.mesh = planet_mesh.create_mesh(ArrayMesh.new())
	#print("Mesh done: ", (Time.get_ticks_usec() - planet.start_time)/1_000_000.0)
	#planet_mesh.mesh.surface_set_material(0,planet_data.surface_material)
