@tool
class_name Topography extends Resource


@export var bedrock:float
@export var stress:float


static func initialise_topography(tiles:Array[Tile],data:PlanetData,mesh:GeometryMesh):
	for t:Tile in tiles:
		t.topography = new()
		t.topography.set_topography(data.surface_noise,mesh.polygons[t.index].get_centre_vertex())



func set_topography(noise:FastNoiseLite,v:Vector3):
	bedrock = noise.get_noise_3dv(v)
