extends CharacterBody2D

var attack_frame = 0

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_collision: CollisionShape2D= $SwordCollision

var is_attacking: bool = false #Flag to check whether the player is attacking

#Play attack animation
func attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	attack_frame = 0 #Reset Attack Frame
	
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player2_jump") and is_on_floor():
		if is_attacking == true:
			is_attacking = false
			animated_sprite.stop()
		velocity.y = JUMP_VELOCITY

	# Skip movement if attacking
	if is_attacking:
		# Only handle attack frame logic when attacking
		# Check current frame of attack animation and enable/disable sword collision
		if animated_sprite.animation == "attack":
			attack_frame = animated_sprite.frame
			
			# Enable sword collision on frames 3 and 4
			if attack_frame == 3 or attack_frame == 4:
				sword_collision.disabled = false
			else:
				sword_collision.disabled = true
				
		move_and_slide()
		return # Return early to block movement when attacking
		
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("player2_move_left", "player2_move_right")
	
	#Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
		sword_collision.position.x = abs(sword_collision.position.x) # Move sword collider to the right side
	elif direction < 0:
		animated_sprite.flip_h = true
		sword_collision.position.x = -abs(sword_collision.position.x) # Move sword collider to the left side
		
		#Play animations
	if is_on_floor():
		if direction == 0 and not is_attacking:
			animated_sprite.play("idle")
		elif direction > 0 or direction < 0 and not is_attacking:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	#Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	if Input.is_action_just_pressed("player2_attack"):
		attack()

	
	

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false # Reset attack state after animation completes
		sword_collision.disabled = true # Disable sword collision after attack
