@tool
class_name GraphicalMesh extends MeshInstance3D


var geometry_mesh:GeometryMesh
var vertex_colours:Array[Color]


func _init() -> void:
	mesh = ArrayMesh.new()
	#geometry_mesh = g_mesh
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_mesh():
	var vertices:PackedVector3Array = geometry_mesh.vertices
	var face_indices:Array[int] = []
	face_indices.resize(geometry_mesh.faces.size()*3)
	for i in range(geometry_mesh.face.size()):
		face_indices[i*3+0] = geometry_mesh.faces[i][0]
		face_indices[i*3+1] = geometry_mesh.faces[i][1]
		face_indices[i*3+2] = geometry_mesh.faces[i][2]
	vertex_colours = []
	vertex_colours.resize(geometry_mesh.get_number_of_vertices())
	
	determine_vertex_colours()
	
	update_mesh_attributes(vertices, face_indices)
	


func determine_vertex_colours():
	var temp_col:Color
	for i in range(geometry_mesh.get_number_of_vertices()):
		temp_col = Color()
		for j in geometry_mesh.vertex_pgon_membership[i]:
			temp_col += geometry_mesh.polygons[j].colour
		temp_col /= geometry_mesh.vertex_pgon_membership[i].size()
		#temp_col *= 255.0
		vertex_colours[i] = Color.from_rgba8(temp_col.r8, temp_col.g8, temp_col.b8, temp_col.a8)


func update_mesh_attributes(vertices:Array[Vector3], face_indices:Array[int]):
	var mesh_arrays:Array[Array] = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_INDEX] = face_indices
	mesh_arrays[Mesh.ARRAY_COLOR] = vertex_colours
	
	var m:ArrayMesh = ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arrays)
	
