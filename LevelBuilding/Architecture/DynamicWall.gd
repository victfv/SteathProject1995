tool

extends Spatial

export var upd = false setget updAll
export var length = 2.0 setget updLen
export (Material) var material setget updMat
export (Mesh) var mesh setget updMesh

const bas = Basis(Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1))

func updLen(a):
	length = a


func updAll(a):
	upd = a
	if a:
		set_process(true)

func _process(delta):
	if upd:
		upd = false
		setUp()
	set_process(false)

func setUp():
	if Engine.editor_hint and is_inside_tree():
		
		for i in get_children():
			i.queue_free()
		
		var r = get_tree().edited_scene_root
		
		var l = ceil(length/4)
		var rest = length/4 - floor(length/4)
		
		var sttc = StaticBody.new()
		sttc.transform.origin = Vector3(-0.05,2,-length/2)
		var shp = CollisionShape.new()
		var bx = BoxShape.new()
		bx.extents = Vector3(0.05, 2, length/2)
		shp.shape = bx
		
		add_child(sttc)
		sttc.add_child(shp)
		
		sttc.owner = r
		shp.owner = r
		
		for i in range(l):
			var n = MeshInstance.new()
			n.use_in_baked_light = true
			add_child(n)
			
			n.owner = r
			print(n.owner.name)
			n.mesh = mesh
			
			n.transform = Transform(bas, Vector3(0,0,-i * 4))
			if rest > 0 and l-1 == i:
				n.scale = Vector3(1,1,rest)
		

func updMat(a):
	material = a
	if Engine.editor_hint and is_inside_tree():
		if get_child_count() > 1:
			var c = get_child(1)
			c.mesh.surface_set_material(0, material)

func updMesh(a):
	mesh = a
	if Engine.editor_hint and is_inside_tree():
		for i in get_children():
			if i is MeshInstance:
				i.mesh = mesh

