#@tool 
class_name PlanetMesh2 extends MeshInstance3D

#region Constants
## Used to correctly position the icosahedron vertices.
const T:float = (1.0 + sqrt(5.0))/2.0
#endregion

@export var data:PlanetData



var vertices:PackedVector3Array
var faces:Array[Array]
var subdivides:Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialise_icosahedron(data.resolution)
	mesh = create_mesh(ArrayMesh.new())
	mesh = alter_mesh(mesh)


func initialise_icosahedron(res):
	vertices = PackedVector3Array()
	#region Push Vertices
	vertices.push_back(Vector3(-1,T,0).normalized())
	vertices.push_back(Vector3(1,T,0).normalized())
	vertices.push_back(Vector3(-1,-T,0).normalized())
	vertices.push_back(Vector3(1,-T,0).normalized())
	
	vertices.push_back(Vector3(0,-1,T).normalized())
	vertices.push_back(Vector3(0,1,T).normalized())
	vertices.push_back(Vector3(0,-1,-T).normalized())
	vertices.push_back(Vector3(0,1,-T).normalized())
	
	vertices.push_back(Vector3(T,0,-1).normalized())
	vertices.push_back(Vector3(T,0,1).normalized())
	vertices.push_back(Vector3(-T,0,-1).normalized())
	vertices.push_back(Vector3(-T,0,1).normalized())
	#endregion
	#region Push Faces
	var init_faces:Array[Array]
	# Faces 0-4 around vertex 0
	init_faces.push_back([5,11,0])
	init_faces.push_back([1,5,0])
	init_faces.push_back([7,1,0])
	init_faces.push_back([10,7,0])
	init_faces.push_back([11,10,0])
	
	# Faces 5-9 adjacent to faces around vertex 0
	init_faces.push_back([9,5,1])
	init_faces.push_back([4,11,5])
	init_faces.push_back([2,10,11])
	init_faces.push_back([6,7,10])
	init_faces.push_back([8,1,7])
	
	# Faces 10-14 around vertex 3
	init_faces.push_back([4,9,3])
	init_faces.push_back([2,4,3])
	init_faces.push_back([6,2,3])
	init_faces.push_back([8,6,3])
	init_faces.push_back([9,8,3])
	
	# Faces 15-19 adjacent to faces around vertex 3
	init_faces.push_back([5,9,4])
	init_faces.push_back([11,4,2])
	init_faces.push_back([10,2,6])
	init_faces.push_back([7,6,8])
	init_faces.push_back([1,8,9])
	
	for f in init_faces:
		subdivide_face(f[0], f[1], f[2], res)


## Recursively subdivides each face of the icosahedron to up to depth
func subdivide_face(v1i:int, v2i:int, v3i:int, depth:int):
	# If we have finished subdividing, create the faces from current sets of vertices and push them
	# to the array
	if depth == 0:
		var vs:PackedInt32Array = []
		vs.push_back(v1i)
		vs.push_back(v2i)
		vs.push_back(v3i)
		faces.push_back(vs)
		return
	
	# Create new vertices at the half way points between existing vertices
	var v1:Vector3 = vertices[v1i]
	var v2:Vector3 = vertices[v2i]
	var v3:Vector3 = vertices[v3i]
	
	var v12 = (v1 + v2).normalized()
	var v23 = (v2 + v3).normalized()
	var v31 = (v3 + v1).normalized()
	
	# Determine the index of the new vertices
	var v12i:int = push_back_subdivided_vertex(v1i,v2i,v12)
	var v23i:int = push_back_subdivided_vertex(v2i,v3i,v23)
	var v31i:int = push_back_subdivided_vertex(v3i,v1i,v31)
	
	# Begin the next layer of subdivision 
	subdivide_face(v1i, v12i, v31i, depth - 1)
	subdivide_face(v2i, v23i, v12i, depth - 1)
	subdivide_face(v3i, v31i, v23i, depth - 1)
	subdivide_face(v12i, v23i, v31i, depth - 1)
	
	return


func subdiv_key(v1i:int,v2i:int):
	if v1i < v2i:
		return str(v1i) + "|" + str(v2i) 
	else:
		return str(v2i) + "|" + str(v1i)


func push_back_subdivided_vertex(v1i:int, v2i:int, v12:Vector3):
	var v12i:int
	var k:String = subdiv_key(v1i,v2i)
	if not subdivides.has(k):
		subdivides[k] = vertices.size()
		v12i = vertices.size()
		vertices.push_back(v12)
	else:
		v12i = subdivides.get(k)
	return v12i


func create_mesh(m:ArrayMesh) -> ArrayMesh:
	var st:SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	
	# Define the vertex data for each face 
	for f in faces:
		# Calculate the shared normal for the vertices in face f
		var e1:Vector3 = vertices[f[1]] - vertices[f[0]] ## Vector equivalent to the face edge from f[0] to f[1]
		var e2:Vector3 = vertices[f[2]] - vertices[f[0]] ## Vector equivalent to the face edge from f[0] to f[2]
		var norm:Vector3 = -e1.cross(e2).normalized() ## Vector of length 1.0 normal to the current face f.
		
		# Set vertex data for each vertex in face f
		for vi in f:
			var v = vertices[vi]
			
			st.set_normal(norm)
			st.add_vertex(v)
	
	return st.commit(m)


func alter_mesh(m:ArrayMesh):
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(m,0)
	
	var num_faces := mdt.get_face_count()
	var depth := data.resolution
	while depth > 0:
		for fi in range(num_faces):
			# Subdivide faces
			# Get vertex indices for current face
			var v0i := mdt.get_face_vertex(fi,0)
			var v1i := mdt.get_face_vertex(fi,1)
			var v2i := mdt.get_face_vertex(fi,2)
			
			# Get vertices of current face
			var v0 := mdt.get_vertex(v0i)
			var v1 := mdt.get_vertex(v1i)
			var v2 := mdt.get_vertex(v2i)
			
			# Create new vertices between current vertices
			var v01 = (v0 + v1).normalized()
			var v12 = (v1 + v2).normalized()
			var v20 = (v2 + v0).normalized()
			
			# Add new vertices to mesh
			#mdt.set_vertex()
			
			#var v01i:int = push_back_subdivided_vertex(v0i,v1i,v01)
			#var v12i:int = push_back_subdivided_vertex(v1i,v2i,v12)
			#var v20i:int = push_back_subdivided_vertex(v2i,v0i,v20)
