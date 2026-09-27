extends CharacterBody3D
class_name Player

# repurposed from gnomes in the autumn wind
# thank you past me
# another past me wrote the above comment
# thank you, both past mes which contributed to this code

const sensitivity := -0.005
const gravity := 16.0
const accconst := 16.0
const friction := 2. ** -2
const jumpspeed := 14.0

var panning: Vector2

func _ready() -> void:
	Global.player = self
	$Camera3D.rotation.y = randf() * TAU
	panning.x = $Camera3D.rotation.y

func _process(delta: float) -> void:
	movementinput(delta)
	pancamera(delta)

func movementinput(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED or Global.world.timeleft == 0:
		return
	var direction := Vector2.ZERO
	if Input.is_action_pressed("forward"):
		direction += Vector2.UP
	if Input.is_action_pressed("back"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("left"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("right"):
		direction += Vector2.RIGHT
	direction = direction.normalized().rotated(-($Camera3D as Node3D).rotation.y)
	velocity += Util.posheight(direction * accconst * delta)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jumpspeed

func pancamera(delta: float) -> void:
	for axis in 2:
		var correction := 1 - 2 ** (delta * -32)
		var spin := (panning[axis] - ($Camera3D as Node3D).rotation[1 - axis]) * correction
		$Camera3D.rotation[1 - axis] += spin
		panning[axis] -= spin
	$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI / 2, PI / 2)

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity.y -= gravity * delta
	for axis in [0, 2]:
		velocity[axis] *= friction ** delta
	if is_on_floor():
		var tangent: Vector3 = Global.world.tangent(Util.coord(position))
		if (velocity + tangent).length() < velocity.length():
			tangent *= 0.75
		velocity += tangent * gravity * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Global.world.timeleft != 0:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			panning += event.relative * sensitivity
