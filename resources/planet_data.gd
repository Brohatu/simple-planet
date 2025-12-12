@tool
class_name PlanetData extends Resource

## Controls the radius of sphere, or the distance from the origin to all surface
## vertices
@export_range(0.1, 10,0.1) var radius:float = 1.0:
	set(val):
		radius = val
		#emit_changed()

## Controls the number of times the original 20 faces of the icosahedron are
## subdivided. 0 leaves the icosahedron unchanged.
@export_range(0,7) var resolution := 5:
	set(val):
		resolution = val
		#emit_changed()


@export var sea_level := 0.0:
	set(val):
		sea_level = val


#region Materials
@export var planet_material:ShaderMaterial:
	set(val):
		planet_material = val
		#emit_changed()

@export var border_material:Material:
	set(val):
		border_material = val
		#emit_changed()



@export var surface_noise:FastNoiseLite

#endregion

#@export var topology

## Number of tectonic plates to initialise
@export_range(10,100) var number_of_plates := 30:
	set(val):
		number_of_plates = val
		#emit_changed()

@export_range(0.0,1.0) var tectonic_plate_ratio := 0.4:
	set(val):
		tectonic_plate_ratio = val
		#emit_changed()
