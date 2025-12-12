@tool
class_name TectonicPlate extends Resource

#@export var shader = preload("res://resources/planet_shaders/plate_shader.gdshader")

## Array of indices referencing the polygons in the [PlanetMesh] that are 
## associated with this [TectonicPlate]
@export var tile_indices:PackedInt32Array
@export var seed_tile_index:int
@export var drift_vector := Vector3.ZERO
@export var plate_colour := Color(randf(),randf(),randf())/4.0
@export var continental := false
@export var edge_tile_indices:PackedInt32Array

var parent_mesh:GeometryMesh
var drift_vector_node:MeshInstance3D
var drift_vector_mesh:ImmediateMesh


## Find all of the tiles in this [TectonicPlate] that are adjacent to tiles
## not in this [TectonicPlate].
func calculate_edge_tiles():
	# Iterate through tiles in this plate
	for pi in tile_indices:
		var p = parent_mesh.polygons[pi]
		# Iterate through tiles adjacent to this tile 
		for api in p.adjacent_polygon_indices:
			# Check if the adjacent tile is not part of this plate
			if !tile_indices.has(api):
				# Check if array of edge tiles already contains this tile
				if !edge_tile_indices.has(pi):
					edge_tile_indices.append(pi)


func draw_rotation_vector():
	drift_vector_mesh = ImmediateMesh.new()
	drift_vector_mesh.clear_surfaces()
	drift_vector_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	drift_vector_mesh.surface_set_color(plate_colour)
	drift_vector_mesh.surface_add_vertex(Vector3.ZERO)
	drift_vector_mesh.surface_add_vertex(drift_vector)
	drift_vector_mesh.surface_end()
	drift_vector_node = MeshInstance3D.new()
	drift_vector_node.mesh = drift_vector_mesh
	return drift_vector_node
