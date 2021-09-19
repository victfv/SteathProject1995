tool

extends Control

# This renders the world to a 256x224 texture to be displayed on screen in an independent resolution from the UI

func _ready():
	if !Engine.editor_hint:
		var rts = MasterScript.player.get_node("CamY/CamX/Camera/RemoteTransform") as RemoteTransform
		rts.remote_path = rts.get_path_to($Viewport/Camera)
		OS.window_maximized = true
	$CenterContainer/WorldTex.texture = $Viewport.get_texture() # Sets the WorldTex texture as the viewport
