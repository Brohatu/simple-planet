@tool
class_name Polygon extends Resource

## The identifying index of this Polygon.
@export var index:int
## An index identifing the vertex the Polygon is centred on. 
@export var center_vertex_index:int
## A list containing the ids of the vertices surrounding the centre vertex,
## outlining the shape of the Polygon.
@export var border_vertex_indices:Array[int]
## A list containing the ids of the surrounding Polygons.
@export var adjacent_polygon_indices:Array[int]
## The square of the distance to the seed tile of the TectonicPlate this Polygon belongs to.
var dist_to_seed:float = INF

#@export var altitude := 0.0
@export var latitude:float
@export var longitude:float
#@export var temperature:float

@export var colour:Color:
	set(val):
		colour = val

@export var drift_vector:Vector3:
	set(val):
		drift_vector = val.normalized()

var parent_mesh:PlanetMesh

static var _index_counter = 0


func _init() -> void:
	border_vertex_indices = []
	adjacent_polygon_indices = []
	index = _index_counter
	_index_counter += 1
	colour = Color.BLACK


func flatten():
	var normalised_centre_vertex := Vector3.ZERO
	for bvi in border_vertex_indices:
		normalised_centre_vertex += parent_mesh.vertices[bvi]
	normalised_centre_vertex /= border_vertex_indices.size()
	parent_mesh.vertices[center_vertex_index] = normalised_centre_vertex


## Returns the latitude and longitude of the centre of the Polygon 
func calculate_latitude_and_longitude():
	var centre_v = get_centre_vertex()
	latitude = asin(centre_v.y) * 180 / PI 
	if centre_v.x == 0:
		longitude = 0;
		return
	longitude = atan(-centre_v.x / centre_v.x)
	var x_offset = PI if centre_v.x else 0.0
	longitude += x_offset
	#longitude = (2.0 * PI + longitude) % 2.0 * PI


func draw_drift_direction():
	var drift_vector_mesh = ImmediateMesh.new()
	drift_vector_mesh.clear_surfaces()
	drift_vector_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	drift_vector_mesh.surface_set_color(Color.WHITE)
	drift_vector_mesh.surface_add_vertex(get_centre_vertex() * 1.01)
	drift_vector_mesh.surface_set_color(Color.BLACK)
	drift_vector_mesh.surface_add_vertex(get_centre_vertex() + (drift_vector * 0.05))
	drift_vector_mesh.surface_set_color(Color.WHITE)
	drift_vector_mesh.surface_add_vertex(get_centre_vertex())
	drift_vector_mesh.surface_end()
	var drift_vector_node = MeshInstance3D.new()
	drift_vector_node.mesh = drift_vector_mesh
	return drift_vector_node


func get_border_vertex(i:int) -> Vector3:
	return parent_mesh.vertices[border_vertex_indices[i]]


func get_centre_vertex():
	return parent_mesh.vertices[center_vertex_index]


func get_vertex_indices():
	var result = []
	result.append(center_vertex_index)
	result.append_array(border_vertex_indices)
	return result
