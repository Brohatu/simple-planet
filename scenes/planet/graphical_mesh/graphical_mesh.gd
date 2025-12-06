@tool
class_name GraphicalMesh extends MeshInstance3D


var geometry_mesh:GeometryMesh
var vertex_colours:PackedColorArray


func initialise(g_mesh:GeometryMesh) -> void:
	mesh = ArrayMesh.new()
	geometry_mesh = g_mesh


func create_mesh():
	var vertices:PackedVector3Array = geometry_mesh.vertices
	var face_indices:PackedInt32Array = []
	#var normals:PackedVector3Array = geometry_mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
	var normals:PackedVector3Array = vertices.duplicate()
	
	face_indices.resize(geometry_mesh.faces.size()*3)
	for i in range(geometry_mesh.faces.size()):
		face_indices[i*3+0] = geometry_mesh.faces[i][0]
		face_indices[i*3+1] = geometry_mesh.faces[i][1]
		face_indices[i*3+2] = geometry_mesh.faces[i][2]
	
	for v in normals:
		v.normalized()
	
	vertex_colours = []
	vertex_colours.resize(geometry_mesh.get_number_of_vertices())
	
	determine_vertex_colours()
	
	update_mesh_attributes(vertices, face_indices, normals)


func determine_vertex_colours():
	var temp_col:Color
	
	for i in range(geometry_mesh.get_number_of_vertices()):
		temp_col = Color()
		if geometry_mesh.vertex_pgon_membership.size() > 0:
			for j in geometry_mesh.vertex_pgon_membership[i]:
				temp_col += geometry_mesh.polygons[j].colour
			temp_col /= geometry_mesh.vertex_pgon_membership[i].size()
		#temp_col *= 255.0
		vertex_colours[i] = Color.from_rgba8(temp_col.r8, temp_col.g8, temp_col.b8, temp_col.a8)
		


func update_mesh_attributes(vertices:PackedVector3Array, face_indices:PackedInt32Array, normals:PackedVector3Array):
	var mesh_arrays:Array = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_INDEX] = face_indices
	mesh_arrays[Mesh.ARRAY_COLOR] = vertex_colours
	mesh_arrays[Mesh.ARRAY_NORMAL] = normals
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arrays)


func update_vertex_colours():
	
