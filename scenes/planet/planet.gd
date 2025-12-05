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

@export_group("Shader Modes")
@export var plate_view := false:
	set(val):
		if geometry_mesh_handler:
			plate_view = val
			geometry_mesh_handler.planet_mesh.set_instance_shader_parameter("show_plates", plate_view)
		else:
			plate_view = false

#@export var temp_view := false:
	#set(val):
		#if planet_mesh:
			#temp_view = val
			#planet_mesh.set_instance_shader_parameter("show_temp", temp_view)
		#else:
			#temp_view = false
#@export var altitude_view := false:
	#set(val):
		#if planet_mesh:
			#altitude_view = val
			#planet_mesh.set_instance_shader_parameter("show_altitude", altitude_view)
		#else:
			#altitude_view = false

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

#endregion

#region Methods
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
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
	
	
	# Prepare rivers
	
	
	# Commit mesh data
	geometry_mesh_handler.commit_meshes(data)
	print("Build done: ", (Time.get_ticks_usec() - start_time)/1_000_000.0, "\n")
	
	# Generate graphics meshes
	graphics_mesh_handler.initialise_graphics(geometry_mesh_handler,data)



#region Tectonic Plates methods
func voronoi_plates(tps:Array[TectonicPlate], unassigned_tiles:Array[Polygon]):
	# Assign each tile to the closest seed tile. 
	while unassigned_tiles.size() > 0:
		var p:Polygon = unassigned_tiles.pop_back()
		## Index of Polygon p
		var pi := p.center_vertex_index
		## The current best plate for the tile. 
		var closest_plate:TectonicPlate
		
		for tp in tps:
			## The position of the seed tile.
			var seed_tile_pos := geometry_mesh_handler.planet_mesh.vertices[tp.seed_tile_index]
			## The position of the current tile.
			var current_tile_pos := geometry_mesh_handler.planet_mesh.vertices[pi]
			# Using distance squared is faster than distance for comparing
			# vectors.
			var dist_2 = current_tile_pos.distance_squared_to(seed_tile_pos)
			
			if dist_2 < p.dist_to_seed:
				closest_plate = tp
				p.dist_to_seed = dist_2
		
		closest_plate.tile_indices.push_back(pi)
		p.drift_vector = closest_plate.drift_vector.cross(p.get_centre_vertex())
		#$DirectionVectors.add_child(p.draw_drift_direction())
		p.colour = closest_plate.plate_colour


func random_fill_plates(tps:Array[TectonicPlate], unassigned_tiles:Array[Polygon]):
	while unassigned_tiles.size() > 0:
		for tp in tps:
			var indices = Array(tp.tile_indices)
			var new_tile
			var tile_to_expand = geometry_mesh_handler.planet_mesh.polygons[indices.pick_random()]
			new_tile = geometry_mesh_handler.planet_mesh.polygons[tile_to_expand.adjacent_polygon_indices.pick_random()]
			if new_tile in unassigned_tiles:
				tp.tile_indices.push_back(new_tile.center_vertex_index)
				unassigned_tiles.erase(new_tile)
				new_tile.drift_vector = tp.drift_vector.cross(new_tile.get_centre_vertex())
				new_tile.colour = tp.plate_colour
				#print("Tiles remaining: ", unassigned_tiles.size())
				#$DirectionVectors.add_child(new_tile.draw_drift_direction())


func generate_tectonic_plates():
	# Initialise temp TectonicPlate array.
	var tps:Array[TectonicPlate] = []
	tps.resize(data.number_of_plates)
	## Array of unassigned Polygons.
	var unassigned_tiles:Array[Polygon] = Array(geometry_mesh_handler.planet_mesh.polygons.duplicate())
	
	# Select a random seed tile for each TectonicPlate.
	for tpi in range(tps.size()):
		## Randomly selected index.
		var selection := randi_range(0, unassigned_tiles.size() - 1) 
		## Random seed tile.
		var p:Polygon = unassigned_tiles.pop_at(selection)
		## Index of seed tile
		var pi := p.center_vertex_index 
		# Create new plate at plate index tpi
		tps[tpi] = TectonicPlate.new()
		# Push seed plate index to plate
		tps[tpi].tile_indices.push_back(p.center_vertex_index)
		tps[tpi].seed_tile_index = pi
		# Assign drift axis to plate
		tps[tpi].drift_vector = Vector3(randf_range(-1.0,1.0),randf_range(-1.0,1.0),randf_range(-1.0,1.0)).normalized()
		# Assign drift direction to seed plate
		p.drift_vector = tps[tpi].drift_vector.cross(p.get_centre_vertex())
		#$DirectionVectors.add_child(p.draw_drift_direction())
		p.colour = tps[tpi].plate_colour
		#p.colour = Color.BLACK
	
	# Fuse nearby plates a few times to get less blocky shapes
	
	# Tiles go to closest plate seed
	#voronoi_plates(tps,unassigned_tiles)
	
	# Plates are expanded at random
	random_fill_plates(tps, unassigned_tiles)
	
	# Calculate tile dependent plate data for each plate
	for tp in tps:
		tp.parent_mesh = geometry_mesh_handler.planet_mesh
		#var rotation_vector = tp.draw_rotation_vector()
		#add_child(rotation_vector)
		tp.calculate_edge_tiles()
	
	# Assign Oceanic plates
	tps = assign_oceanic_plates(tps)
	tectonic_plates = tps
	
	print("Tectonic Plates done: " + str((Time.get_ticks_usec() - start_time)/1_000_000.0))


func assign_oceanic_plates(tps:Array[TectonicPlate]):
	var ratio := data.tectonic_plate_ratio
	var continental_plates:Array[TectonicPlate] = []
	for i in range(tps.size() * ratio):
		var selected_plate = 0
		while !selected_plate:
			selected_plate = tps.pick_random()
			if not continental_plates.has(selected_plate):
				selected_plate.continental = true
				continental_plates.push_back(selected_plate)
			else:
				selected_plate = 0
	
	#for tp in tps:
		#if tp.continental:
			#tp.plate_colour = Color.DARK_GREEN
		#else:
			#tp.plate_colour = Color.BLUE
	
	return tps


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
