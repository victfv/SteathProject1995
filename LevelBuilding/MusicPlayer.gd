extends Node

var state = 0
var nextState = 0
# 0 - calm
# 1 - suspense
# 2 - action
var switching = false

func _ready():
	pass

func _process(delta):
	if MasterScript.alertLevel > 0.2:
		$Suspense.volume_db = clamp($Suspense.volume_db + delta * 48, -48, 0)
		if MasterScript.alertLevel > 0.6:
			$Action.volume_db = clamp($Action.volume_db + delta * 48, -48, 0)
		else:
			$Action.volume_db = clamp($Action.volume_db - delta * 24, -48, 0)
	else:
		$Suspense.volume_db = clamp($Suspense.volume_db - delta * 24, -48, 0)
