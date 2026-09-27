extends Node
class_name World

const sidelength := int(2 ** 8 * 1.5)
const subdivs := sidelength - 1
const heightoffset := 2. ** -3
const heightscale := 2. ** 6
const leafquant := int(sidelength ** 2 * 2. ** -7)
const leafthresh := 0.5

@export var boardmat: ShaderMaterial
@export var noise: FastNoiseLite
@export var leafnoise: FastNoiseLite

var leafs: Array[Leaf]
var score: int
var time: float
var timeleft: float = 180
var finished: bool = false
var finalscore: int

class Leaf:
	
	const spinspeed := 0.5
	const wobblespeed := 1.0
	const height := 1.0
	const wobble := 0.2
	
	var multimesh: MultiMesh
	var meshindex: int
	var scalar: float
	
	var position: Vector3
	var spin: float
	
	var crunchd: bool = false
	
	func create(meshindexin: int) -> void:
		meshindex = meshindexin
		multimesh = Global.world.get_node("MultiLeaf").multimesh
		scalar = 2 ** randf_range(-0.5, 0.5)
		multimesh.set_instance_color(meshindex, Color(1, randf(), 0))

	func bealeaf(delta: float) -> void:
		if crunchd:
			position.y -= 12 * delta
			spin += spinspeed * 4 * TAU * delta
		else:
			position.y = Global.world.height(Util.coord(position)) + sin(Global.world.time * TAU * wobblespeed) * wobble + height
			spin = Global.world.time * TAU * spinspeed
		var leafbasis := Basis(Vector3.UP, spin) * scalar
		multimesh.set_instance_transform(meshindex, Transform3D(leafbasis, position))

	func touch() -> void:
		if not crunchd and (Global.player.position + Vector3.UP * 2.25 - position).length() <= 8:
			crunchd = true
			Global.world.eatleaf(self)


func height(point: Vector2) -> float:
	return (noise.get_noise_2dv(point) + heightoffset) * heightscale

func tangent(point: Vector2) -> Vector3:
	var slope := Vector3.ZERO
	for axis in 2:
		var disp := Vector2.ZERO
		disp[axis] = 0.001
		slope[axis * 2] = (height(point + disp) - height(point - disp)) / 0.002
	slope.y = 1
	slope = -slope.normalized()
	return slope

func randpoint() -> Vector2:
	while true:
		var point := Util.randv2(true, sidelength / 2)
		if height(point) >= 1:
			return point
	return Vector2.ZERO  # to satisfy static typing constraints

func randpos() -> Vector3:
	var point := randpoint()
	return Util.posheight(point, height(point))

func underwater() -> bool:
	return $Player/Camera3D.global_position.y <= 0.2

func zeropad(number: int, zeros: int) -> String:
	var text := str(number)
	return "0".repeat(zeros - text.length()) + text

func create() -> void:
	setupnoise()
	unfold()
	raiseboard()
	dropleafs()
	enclose()
	play()

func _process(delta: float) -> void:
	if underwater():
		delta *= 4
	time += delta
	timeleft = max(timeleft - delta, 0)
	updatelabel()
	careforleafs(delta)
	considerswimming()
	considerfinishing()

func setupnoise() -> void:
	for noiseobj in [noise, leafnoise]:
		noiseobj.seed = randi()
		noiseobj.offset = Util.randv3(true, 2 ** 10)

func unfold() -> void:
	for plane in [$Board, $Water]:
		plane.mesh.size = Vector2.ONE * sidelength
		plane.mesh.subdivide_width = subdivs
		plane.mesh.subdivide_depth = subdivs

func raiseboard() -> void:
	var startmesh := ArrayMesh.new()
	startmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, $Board.mesh.get_mesh_arrays())
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(startmesh, 0)
	for veriter in mdt.get_vertex_count():
		var vertex := mdt.get_vertex(veriter)
		mdt.set_vertex(veriter, vertex + Vector3.UP * height(Util.coord(vertex)))
	var amesh := ArrayMesh.new()
	mdt.commit_to_surface(amesh)
	var st := SurfaceTool.new()
	st.create_from(amesh, 0)
	st.generate_normals()
	amesh = st.commit()
	amesh.surface_set_material(0, boardmat)
	$Board.mesh = amesh
	$Board.create_trimesh_collision()

func dropleafs() -> void:
	$MultiLeaf.multimesh.instance_count = leafquant
	for leafiter in leafquant:
		var leaf := Leaf.new()
		leafs.append(leaf)
		while true:
			var leafpos := randpoint()
			var sample := remap(leafnoise.get_noise_2dv(leafpos), -1, 1, 0, 1) 
			if sample >= leafthresh and randf() < ((sample - leafthresh) / (1 - leafthresh)) ** 2:
				leaf.position = Util.posheight(leafpos)
				break
		leaf.create(leafiter)

func enclose():
	for side in 4:
		var angle := side * PI / 2
		var colshape := CollisionShape3D.new()
		colshape.shape = WorldBoundaryShape3D.new()
		colshape.shape.plane = Plane(Vector3.RIGHT.rotated(Vector3.UP, angle), -sidelength / 2)
		$OuterBounds.add_child(colshape)

func careforleafs(delta: float) -> void:
	for leaf in leafs.duplicate():
		leaf.bealeaf(delta)
		leaf.touch()

func considerswimming() -> void:
	$SwimmingRect.color.a = 0.4 if underwater() else 0

func considerfinishing() -> void:
	if timeleft != 0 or finished:
		return
	finished = true
	finalscore = score
	if finalscore == leafquant:
		$EndLabel.text += "\nAll Leafs!!!"
	$EndLabel.text += "\n[R] to Restart\n"
	$EndLabel.text += "\nFinal Leafs: " + zeropad(finalscore, 4)
	$EndLabel.text += "\nBest: " + zeropad(Global.hileaf, 4)
	Global.hileaf = max(Global.hileaf, finalscore)

func play() -> void:
	$Player.position = randpos()

func eatleaf(leaf: Leaf) -> void:  # i know calling up is bad practice but i'm a bad boy
	if Global.sfxon:
		$LeafTouchAudio.pitch_scale = 2. ** randf_range(0, 0.5)
		$LeafTouchAudio.play()
	score += 1

func updatelabel() -> void:
	$StatLabel.text = ""
	$StatLabel.text += "Time:  " + zeropad(int(timeleft), 3) + "\n"
	$StatLabel.text += "Leafs: " + str(score)
