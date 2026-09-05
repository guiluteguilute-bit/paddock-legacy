extends Label

# Replaced in the CI runner before export. The development_build feature can be
# removed from the export preset to hide this label in a future commercial build.
const BUILD_COMMIT: String = "local"
const BUILD_SHORT_COMMIT: String = "local"
const BUILD_NUMBER: String = "0"
const BUILD_DATE: String = "development"
const BUILD_BRANCH: String = "local"
const BUILD_ENVIRONMENT: String = "development"


func _ready() -> void:
	visible = OS.has_feature("development_build")
	if visible:
		text = "PADDOCK LEGACY • %s BUILD • %s (#%s)" % [BUILD_ENVIRONMENT.to_upper(), BUILD_SHORT_COMMIT, BUILD_NUMBER]
