@tool
class_name Planet extends Node3D
# Class for building and managing Planet generation and data.


#region Properties
@export var data:PlanetData:
	set(val):
		data = val
		print("Planet data update")
		if data != null and not data.is_connected("changed", build):
			data.connect("changed", build)

##@export var g_data:GridData:
	##set(val):
		##g_data = val
		##print("Grid data update")
		##if g_data != null and not g_data.is_connected("changed", build_grid):
			##g_data.connect("changed", build_grid)

@export var tectonic_plates:Array[TectonicPlate]
@export var tiles:Array[Tile]
@export var random_seed:int

@export var grid_on := true:
	set(val):
		if graphics_mesh_handler:
			grid_on = val
			graphics_mesh_handler.grid_mesh.visible = val
			geometry_mesh_handler.grid_mesh.visible = val

@export_group("Shader Modes")
@export var plate_view := false:
	set(val):
		plate_view = val
		
		
		
		
		
		var colours:PackedColorArray = []
		colours.resize(geometry_mesh_handler.planet_mesh.vertices.size())
		for t in tiles:
			#var tile_col = t.geometry.colour
			colours[t.index] = t.geometry.colour
		graphics_mesh_handler.update_graphics(geometry_mesh_handler.planet_mesh,colours)
		data.planet_material.set_shader_parameter("show_plates", val)

@export var temp_view := false#:
	#set(val):
		#if planet_mesh:
			#temp_view = val
			#planet_mesh.set_instance_shader_parameter("show_temp", temp_view)
		#else:
			#temp_view = false
@export var altitude_view := false:
	set(val):
		altitude_view = val
		
@export var stereographic:bool:
	set(val):
		data.planet_material.set_shader_parameter("stereographic", val)
		stereographic = val



@export_group("Regenerate Planet")
@export var rebuild := false:
	set(val):
		rebuild = false
		build()


#@export var regen_climate := false:
	#set(val):
		#regen_climate = false
		#start_time = Time.get_ticks_usec()
		#for p in planet_mesh.polygons:
			#p.altitude = 0.0
			#p.temperature = 0.0
		#generate_climate()

#@export var regen_plates := false:
	#set(val):
		#regen_plates = false
		#tectonic_plates.clear()
		#for p in planet_mesh.polygons:
			#p.colour = Color.BLACK
		#generate_tectonic_plates()
		#generate_climate()

#@export_group("Parameter ranges")
#@export var max_alt := 0.0
#@export var min_alt := 0.0
#@export var max_temp := 0.0
#@export var min_temp := 0.0

var start_time:float

@onready var geometry_mesh_handler := $GeometryMeshHandler as GeometryMeshHandler
@onready var graphics_mesh_handler := $GraphicalMeshHandler as GraphicalMeshHandler
@onready var plate_handler := $PlateHandler as PlateHandler
@onready var tile_handler := $TileHandler
#endregion

#region Methods
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build()
	# Build mesh
	
	# Build tiles
	
	#
	
	#if !data:
		#data = PlanetData.new()
	#if !g_data:
		#g_data = GridData.new()
	#build()
	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#rebuild = true
	pass


func build():
	seed(random_seed)
	print("Starting planet build.")
	start_time = Time.get_ticks_usec()
	# Generate planet geometry
	geometry_mesh_handler.initialise_planet_meshes(data)
	
	Tile.create_tiles(self)
	
	# Create plates
	tectonic_plates = PlateHandler.generate_tectonic_plates(geometry_mesh_handler.planet_mesh, data)
	print("Tectonic Plates done: " + str((Time.get_ticks_usec() - start_time)/1_000_000.0))
	
	# Prepare topography
	Topography.initialise_topography(tiles,data,geometry_mesh_handler.planet_mesh)
	#for t in tiles:
		#t.topography.bedrock = data.surface_noise.get_noise_3dv(geometry_mesh_handler.planet_mesh.polygons[t.index].get_centre_vertex())
	
	
	
	# Prepare rivers
	
	
	# Commit mesh data
	geometry_mesh_handler.commit_meshes(data)
	print("Build done: ", (Time.get_ticks_usec() - start_time)/1_000_000.0, "\n")
	
	# Generate graphics meshes
	graphics_mesh_handler.initialise_graphics(geometry_mesh_handler.planet_mesh,data.planet_material)
	graphics_mesh_handler.initialise_grid(geometry_mesh_handler.grid_mesh,data.border_material)



#region Tectonic Plates methods

##func set_tile_colours():
	##var arrays = planet_mesh_inst.mesh.surface_get_arrays(0)
	##var col_arr = arrays[Mesh.ARRAY_COLOR]
	###for 
#
#endregion

#region Climate methods
#func generate_climate():
	## Prepare latitude and longitude of polygons
	#for p in planet_mesh.polygons:
		#p.calculate_latitude_and_longitude()
	#calculate_altitude()
	#planet_mesh.set_instance_shader_parameter("sea_level", data.sea_level)
	#calculate_temperature()
	#print("Climate done: " + str((Time.get_ticks_usec() - start_time)/1_000_000.0))


#func calculate_temperature():
	#for tp in tectonic_plates:
		#for pi in tp.tile_indices:
			#var p := planet_mesh.polygons[pi]
			#var temp_lat := calculate_latitude_temp(abs(p.latitude))
			#var temp_alt := 0.0
			#if p.altitude > data.sea_level:
				#temp_alt -= p.altitude - data.sea_level - 5.0 
			#else:
				#p.temperature -= 5.0
			#p.temperature = temp_lat + temp_alt
			
			#if p.temperature > max_temp:
				#max_temp = p.temperature
			#elif p.temperature < min_temp:
				#min_temp = p.temperature
	#planet_mesh.set_instance_shader_parameter("min_temp", min_temp)
	#planet_mesh.set_instance_shader_parameter("max_temp", max_temp)


### Calculates the variation in temperature due to latitude. Ranges from +30 at
### the equator to -20 at the poles.
#func calculate_latitude_temp(lat:float) -> float:
	## Scale latitude to range from 0 to 50
	#var result := (-lat + 90.0) * 5.0/9.0
	## Subtract 20 to get range -20 to 30
	#result -= 20.0
	#return result
#
#
### Calculates the altitude of each tile. Mountains and rift valleys are calculated
### using the drift vectors of each tile. Finer details is then overlaid by sampling
### noise. 0.001 is equivalent to 1 metre
#func calculate_altitude():
	#max_alt = 0.0
	#min_alt = 0.0
	#
	#for tp in tectonic_plates:
		### Generate mountains and rift valleys
		#for pi in tp.edge_tile_indices:
			#var total_stress := 0.0
			#var p := planet_mesh.polygons[pi]
			#for api in p.adjacent_polygon_indices:
				#var ap := planet_mesh.polygons[api]
				#if p.colour != ap.colour:
					#total_stress += p.drift_vector.dot(ap.drift_vector)
					#p.altitude += total_stress
		#
		### Offset Oceanic and Continental plates
		#for pi in tp.tile_indices:
			#var p := planet_mesh.polygons[pi]
			#if tp.continental:
				#p.altitude += 2.5
			#else:
				#p.altitude -= 2.5
			#
			### Set either new max_alt or min_alt if appropriate
			#if p.altitude > max_alt:
				#max_alt = p.altitude
			#elif p.altitude < min_alt:
				#min_alt = p.altitude
	#
	#
	#
	##planet_mesh_inst.set_instance_shader_parameter("surface_noise", data.surface_noise)
	#planet_mesh.set_instance_shader_parameter("min_alt", min_alt)
	#planet_mesh.set_instance_shader_parameter("max_alt", max_alt)


#endregion


#endregion
