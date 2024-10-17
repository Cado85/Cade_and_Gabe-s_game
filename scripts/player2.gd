extends CharacterBody2D

var attack_frame = 0
var health = 3
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var movement = Vector2(0,0)

const DAMAGE_KNOCKBACK = 200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var char_collision: CollisionShape2D= $CollisionShape2D
@onready var sword_collision: CollisionShape2D= $SwordHitbox/SwordCollision
@onready var invincibility_timer: Timer = $InvincibilityTimer


var is_attacking: bool = false #Flag to check whether the player is attacking
var is_damaged: bool = false
var is_invincible: bool = false

#Play attack animation
func attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	attack_frame = 0 #Reset Attack Frame
	
	

# Function to activate invincibility
func invincibility() -> void:
	if not is_invincible:
		is_invincible = true
		#char_collision.disabled = true  # Disable collision
		invincibility_timer.start()  # Start the 3-second timer
		print("Invincibility activated!")


# This function will be called when the timer finishes
func _on_invincibility_timer_timeout():
	is_invincible = false
	#char_collision.disabled = false  # Enable collision
	animated_sprite.stop()  # Stop the damage animation when invincibility ends
	print("Invincibility ended!")
	
	# Reset the damage flag
	is_damaged = false
	
	# Reset animation to idle or run depending on current movement
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")  # Return to idle if not moving
		else:
			animated_sprite.play("run")  # Return to run if moving
	else:
		animated_sprite.play("jump")  # If player is mid-air
		

# Play the damage animation and apply knockback
func play_damage_animation() -> void:
	if not is_invincible:  # Only start invincibility if not already invincible
		is_damaged = true
		invincibility()  # Activate invincibility when taking damage
		animated_sprite.play("damaged")  # Play the damaged animation




	
func _physics_process(delta: float) -> void:
	if GameManager.player1_hits == true:
		play_damage_animation()
		is_damaged = true
		health -= 1
		print(health)
		GameManager.player1_hits = false

		
	if health <= 0:
		queue_free()
		
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
		if direction == 0 and not is_attacking and not is_damaged:
			animated_sprite.play("idle")
		elif direction > 0 or direction < 0 and not is_attacking and not is_damaged:
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

	
func player2():
	pass


		
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false # Reset attack state after animation completes
		sword_collision.disabled = true # Disable sword collision after attack
