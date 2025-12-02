@tool
class_name PolygonGrid extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


static func generate_grid_from_mesh(grid_mesh:GeometryMesh, planet_mesh:GeometryMesh, line_width:float):
	
	var vs:PackedVector3Array = []
	var fs:Array[PackedInt32Array]= []
	var counter := 0
	var first_vert_in_pgon_index:int
	
	for p:Polygon in planet_mesh.polygons:
		first_vert_in_pgon_index = counter
		for bvi in range(p.border_vertex_indices.size()):
			vs.push_back(line_width * p.get_border_vertex(bvi))
			vs.push_back(line_width * lerp(p.get_centre_vertex(), p.get_border_vertex(bvi), 1.0 - line_width))
			
			if (bvi != p.border_vertex_indices.size() - 1):
				fs.push_back(PackedInt32Array([counter, counter + 3, counter + 1]))
				fs.push_back(PackedInt32Array([counter, counter + 2, counter + 3]))
			else:
				fs.push_back(PackedInt32Array([counter, first_vert_in_pgon_index + 1, counter + 1]))
				fs.push_back(PackedInt32Array([counter, first_vert_in_pgon_index, first_vert_in_pgon_index + 1]))
			
			counter += 2
	
	for v in vs:
		v.normalized()
	grid_mesh.vertices = vs
	grid_mesh.faces = fs
	grid_mesh.polygons = planet_mesh.polygons.duplicate()
	#grid.vertex_radius = ts.vertex_radius
	#grid.vertices_in_polygon = ts.vertices_in_polygon
	#return grid
