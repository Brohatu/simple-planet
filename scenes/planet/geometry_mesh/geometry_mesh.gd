@tool
class_name GeometryMesh extends MeshInstance3D

#region Constants
## Used to correctly position the icosahedron vertices.
static var T := (1.0 + sqrt(5.0))/2.0
#endregion


#region Variables
## Array of vertices making up the Icosphere
@export var vertices:PackedVector3Array

## Array of face arrays. Each face f contains the index of the three vertices that
## make up the triangle.
@export var faces:Array[PackedInt32Array]

## An array containing a record of the length of each vertex vi.
var vertex_radius:Array

## Keeps a record of the assigned indices in the vertex array
var subdivides:Dictionary

## Array of Polygons that make up the derived Hexsphere.
@export var polygons:Array[Polygon]

## List of Polygons vertex vi belongs to.
var vertex_pgon_membership:Array[Array]

## List of vertices in Polygon pi.
var vertices_in_polygon:Array[Array]

## Maps each set of triangles to a Polygon. 
var triangle_to_polygon_map:Dictionary

#@onready var polygon_grid = $PolygonGrid
#endregion



#region Methods
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generate_icosahedron(0)
	#create_mesh(ArrayMesh.new())
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#region Creating vertices and faces
## Defines the vertices and triangles of the mesh for the base icosahedron, 
## then subdivides the faces to calculate the rest of the vertices and faces of
## the icosphere.
func generate_icosahedron(res:int):
	# Define initial 12 icosahedron vertices and push them to vertex array
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
	
	# Define intital 20 icosohedron faces and push them to face array
	#region Push Faces
	var init_faces:Array = []
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
	#endregion
	
	# Subdivide the icosahedron faces to get the correct resolution
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
#endregion


#region Tessalation Methods

func tesselate_ico_mesh():
	initialise_polygons(vertices.size())
	determine_pgon_adjacency()
	divide_triangle_faces()
	_sort_vertices()
	_sort_adjacency()
	_create_polygon_faces()


## Creates a new Polygon for each vertex on the isosphere 
func initialise_polygons(num_of_pgons:int):
	Polygon._index_counter = 0
	for pi in range(num_of_pgons):
		polygons.push_back(Polygon.new())
		polygons[pi].parent_mesh = self
		polygons[pi].center_vertex_index = pi
		var new_array:Array[int] = [pi]
		vertex_pgon_membership.push_back(new_array)
		vertices_in_polygon.push_back([])
		vertices_in_polygon[pi].push_back(pi)


## Noramlises the length of all vertex position vectors to give a sphere with 
## the given radius. Radius defaults to 1.0. 
func normalise(radius:float = 1.0):
	for vi in range(vertices.size()):
		vertices[vi] = vertices[vi].normalized() * radius
	for p in polygons:
		p.flatten()


## 
func determine_pgon_adjacency():
	var adj_connection_already_done:Dictionary = {}
	for f in faces:
		add_pgon_adjacency_if_not_done_yet(adj_connection_already_done,f[0],f[1])
		add_pgon_adjacency_if_not_done_yet(adj_connection_already_done,f[1],f[2])
		add_pgon_adjacency_if_not_done_yet(adj_connection_already_done,f[2],f[0])


##
func add_pgon_adjacency_if_not_done_yet(adj_connection_already_done:Dictionary, x:int, y:int):
	if(!adj_connection_already_done.has(str(x) + "-" + str(y))):
		polygons[x].adjacent_polygon_indices.push_back(y)
		polygons[y].adjacent_polygon_indices.push_back(x)
		
		adj_connection_already_done.set(str(x) + "-" + str(y),true)
		adj_connection_already_done.set(str(y) + "-" + str(x),true)


## 
func divide_triangle_faces():
	var f:Array
	var centre_v:Vector3
	var vertex_counter = vertices.size()
	
	for i in range(faces.size()):
		f = faces[i]
		centre_v = (vertices[f[0]]+vertices[f[1]]+vertices[f[2]]).normalized()
		vertices.push_back(centre_v)
		link_vertex_to_polygons(f,vertex_counter)
		vertex_counter += 1


## Attributes each polygon vertex to the triangles it is part of. 
func link_vertex_to_polygons(f:Array,vi:int):
	polygons[f[0]].border_vertex_indices.push_back(vi)
	polygons[f[1]].border_vertex_indices.push_back(vi)
	polygons[f[2]].border_vertex_indices.push_back(vi)
	
	vertex_pgon_membership.push_back([])
	vertex_pgon_membership[vi].push_back(f[0])
	vertex_pgon_membership[vi].push_back(f[1])
	vertex_pgon_membership[vi].push_back(f[2])
	
	#vertices_in_polygon.push_back([])
	vertices_in_polygon[f[0]].push_back(vi)
	vertices_in_polygon[f[1]].push_back(vi)
	vertices_in_polygon[f[2]].push_back(vi)


func _sort_vertices():
	for p in polygons:
		_order_vertices_by_position(p)
		_make_vertices_ccw(p)


func _order_vertices_by_position(p:Polygon):
	var poly_sorted_vs:Array[int] = []
	var poly_unsorted_vs:Array[int]
	var min_dist:float
	var closest_index:int = 0
	var last_vi_added:int
	
	poly_unsorted_vs = p.border_vertex_indices.duplicate()
	poly_sorted_vs.push_back(poly_unsorted_vs[0])
	last_vi_added = poly_unsorted_vs[0]
	poly_unsorted_vs.remove_at(0)
	
	while poly_unsorted_vs.size() > 0:
		min_dist = INF
		for vi in poly_unsorted_vs:
			if vertices[last_vi_added].distance_to(vertices[vi]) < min_dist:
				closest_index = vi
				min_dist = vertices[last_vi_added].distance_to(vertices[vi])
		
		poly_sorted_vs.push_back(closest_index)
		poly_unsorted_vs.erase(closest_index)
		last_vi_added = closest_index
	
	p.border_vertex_indices = poly_sorted_vs.duplicate()


func _make_vertices_ccw(p:Polygon):
	var v1:Vector3 = vertices[p.center_vertex_index] - vertices[p.border_vertex_indices[0]]
	var v2:Vector3 = vertices[p.center_vertex_index] - vertices[p.border_vertex_indices[1]]
	if vertices[p.center_vertex_index].dot(v1.cross(v2)) > 0:
		p.border_vertex_indices.reverse()


## Sorts the list of adjacent Polygons to be in the same order as the border vertices.
func _sort_adjacency():
	#var i:int = 0
	var neighbour_indices_sorted:Array[int]
	for p in polygons:
		neighbour_indices_sorted.clear()
		for bvi in range(p.border_vertex_indices.size()-1):
			neighbour_indices_sorted.push_back(_get_adj_pgon_from_vertices(p, bvi, bvi+1))
		
		neighbour_indices_sorted.push_back(_get_adj_pgon_from_vertices(p, 0, p.border_vertex_indices.size()-1))
		p.adjacent_polygon_indices = neighbour_indices_sorted.duplicate()
		
		#print(i)
		#i += 1


## Returns the index vertex of an adjacent polygon.
func _get_adj_pgon_from_vertices(p:Polygon, bvi_1:int, bvi_2:int):
	for pi_a in vertex_pgon_membership[p.border_vertex_indices[bvi_1]]:
		for pi_b in vertex_pgon_membership[p.border_vertex_indices[bvi_2]]:
			if pi_a == pi_b and pi_a != p.index:
				return pi_b
	
	print("Error inside adjacency sorting")
	return -1


func _create_polygon_faces():
	var face_counter:int = 0
	var p:Polygon
	for pi in range(polygons.size()):
		p = polygons[pi]
		for bvi in range(p.border_vertex_indices.size() - 1):
			var f:PackedInt32Array = [p.center_vertex_index,p.border_vertex_indices[bvi],p.border_vertex_indices[bvi+1]]
			faces.push_back(f)
			triangle_to_polygon_map.set(face_counter, pi)
			face_counter += 1
		var f1:PackedInt32Array = [p.center_vertex_index,p.border_vertex_indices[p.border_vertex_indices.size() - 1],p.border_vertex_indices[0]]
		faces.push_back(f1)
		triangle_to_polygon_map.set(face_counter,pi)
		face_counter += 1

#endregion


#region Mesh Methods
## Takes an ArrayMesh and assigns it a new icosahedron surface.
func create_mesh(m:ArrayMesh) -> ArrayMesh:
	var st:SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Define the vertex data for each face 
	for f in faces:
		var e1:Vector3 = vertices[f[1]] - vertices[f[0]] ## Vector equivalent to the face edge from f[0] to f[1]
		var e2:Vector3 = vertices[f[2]] - vertices[f[0]] ## Vector equivalent to the face edge from f[0] to f[2]
		var norm:Vector3 = -e1.cross(e2).normalized() ## Vector of length 1.0 normal to the current face f.
		
		for vi in f:
			# Find the vertex with index vi in vertices
			var v:Vector3 = vertices[vi]
			
			#if vi < polygons.size():
				#if polygons[vi].altitude < 0.0:
					#st.set_custom()
				#st.set_color(polygons[vi].colour)
			
			st.set_normal(norm)
			
			if vi < polygons.size():
				# Set custom data for tile vertices.
				# Custom 0 contains unique plate colour
				st.set_custom_format(0,SurfaceTool.CUSTOM_RGB_FLOAT)
				st.set_custom(0,polygons[vi].colour)
				# Custom 1 contains altitude, temperature,
				#st.set_custom_format(1,SurfaceTool.CUSTOM_RGB_FLOAT)
				#st.set_custom(1,Color(polygons[vi].altitude,polygons[vi].temperature,0.0))
			st.add_vertex((v))
	
	return st.commit(m)


#func create_grid_from_mesh(line_width:float):
	#polygon_grid.generate_grid_from_mesh(self,line_width)

#endregion


func clear():
	vertices.clear()
	faces.clear()
	polygons.clear()
	vertex_pgon_membership.clear()
	triangle_to_polygon_map.clear()
	vertex_radius.clear()
	subdivides.clear()
	vertices_in_polygon.clear()


#endregion
