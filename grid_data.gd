class_name GridData extends Resource


@export var line_width := 0.1:
	set(val):
		line_width = val
		emit_changed()
