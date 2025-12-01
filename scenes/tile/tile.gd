@tool
class_name Tile extends Node3D
#
##region Variables
#static var selectedTile:Tile
#
#@export var temperature := 0.0
#@export var altitude := 0.0
#@export var geometry:Polygon
#var index:int
#
#
##endregion
#
##region Methods
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
##region Static Methods
#static func create_tiles(planet:Planet):
	#var tiles:Array[Tile]
	#
	#for i in planet.mesh_handler.planet_mesh.polygons.size():
		#tiles.push_back(Tile.new())
		#tiles[i].init_geometry(planet.mesh_handler.planet_mesh.polygons[i])
		#
#
##endregion
#
#func init_geometry(p:Polygon):
	#geometry = p
	#geometry.calculate_latitude_and_longitude()
	## Calculate area
#
#
#
#func calculate_altitude():
	#pass
#
#
#func calculate_temperature():
	#pass
#
##endregion
