extends Label

# Replaced in the CI runner before export. The development_build feature can be
# removed from the export preset to hide this label in a future commercial build.
const BUILD_COMMIT := "local"


func _ready() -> void:
	visible = OS.has_feature("development_build")
	if visible:
		text = "DEVELOPMENT BUILD  •  Commit: %s" % BUILD_COMMIT

