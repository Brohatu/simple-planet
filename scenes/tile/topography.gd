@tool
class_name Topography extends Resource


@export var bedrock:float
@export var stress:float


static func initialise_topography(tiles:Array[Tile]):
	for t:Tile in tiles:
		t.topography = new()
