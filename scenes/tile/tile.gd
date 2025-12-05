@tool
class_name Tile extends Node3D

#region Variables
static var selectedTile:Tile

## Average temperature of tile in degrees Celsius.
@export var temperature := 0.0
## Average altitude of tile in metres.
@export var altitude := 0.0
@export var precipitation := 0.0
## Compass direction of prevailing winds.
@export var wind := Vector2.ZERO
## [Polygon] geometry associated with this tile.
@export var geometry:Polygon
var index:int

var _attribute_getter:Dictionary[String, Callable] = {}

#endregion

#region Methods

#region Static Methods
static func create_tiles(planet:Planet):
	var tiles:Array[Tile]
	
	for i in planet.geometry_mesh_handler.planet_mesh.polygons.size():
		tiles.push_back(Tile.new())
		tiles[i].init_geometry(planet.geometry_mesh_handler.planet_mesh.polygons[i])
		planet.tile_handler.add_child(tiles[i])
	
	Polygon.assign_adjacency_data(tiles, planet.geometry_mesh_handler.planet_mesh.polygons)
	
	planet.tiles = tiles

#endregion

func init_geometry(p:Polygon):
	geometry = p
	geometry.calculate_latitude_and_longitude()
	# Calculate area


func intitialise_attribute_getter():
	_attribute_getter["temperature"] = func(tile): return tile.climate.temperature
	_attribute_getter["altitude"] = func(tile): return tile.topography.altitude
	_attribute_getter["precipitation"] = func(tile): return tile.climate.precipitation
	# Add more 


func get_attribute(key:String) -> float:
	var val:float
	if _attribute_getter.has(key):
		val = _attribute_getter[key].call(self)
	else:
		val = 0.0
	
	return val


func calculate_altitude():
	pass


func calculate_temperature():
	pass

#endregion
