extends Node

var state = 0
var nextState = 0
# 0 - calm
# 1 - suspense
# 2 - action
var switching = false

func _ready():
	pass

#func _process(delta):
#	if MasterScript.alertLevel < 0.5 and nextState != 0:
#		nextState = 0
#		$SwitchTimer.start()
#	elif MasterScript.alertLevel < 1.0 and nextState != 1:
#		nextState = 1
#		$SwitchTimer.start()
#	elif nextState != 2:
#		nextState = 2
#		$SwitchTimer.start()
#
#	switchSong(delta)
#
#
#
#func switchSong(delta):
#	$Calm.volume_db = lerp($Calm.volume_db, int(!state == 0) * - 48, delta * 48)
#	$Suspense.volume_db = lerp($Suspense.volume_db, int(!state == 1) * - 48, delta * 48)
#	$Action.volume_db = lerp($Action.volume_db, int(!state == 2) * - 48, delta * 48)
