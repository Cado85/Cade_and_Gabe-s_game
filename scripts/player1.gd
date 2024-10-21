extends CharacterBody2D

var attack_frame = 0
var health = 3
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var movement = Vector2(0,0)

const DAMAGE_KNOCKBACK = 1000.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var char_collision: CollisionShape2D= $CollisionShape2D
@onready var sword_collision: CollisionShape2D= $Area2D/SwordCollision
@onready var invincibility_timer: Timer = $InvincibilityTimer


var is_attacking: bool = false #Flag to check whether the player is attacking
var is_damaged: bool = false
var is_invincible: bool = false
var is_dead: bool = false
var facing_right: bool = false

# Function to update animation set based on health
func update_animation_set() -> void:
	if health == 2:
		animated_sprite.animation = "idle_2"
	elif health == 1:
		animated_sprite.animation = "idle_1"
	else:
		animated_sprite.animation = "idle"

#Play attack animation
func attack() -> void:
	is_attacking = true
	attack_frame = 0  # Reset Attack Frame
	if health == 3:
		animated_sprite.play("attack")
	elif health == 2:
		animated_sprite.play("attack_2")
	elif health == 1:
		animated_sprite.play("attack_1")
	
	

# Function to activate invincibility
func invincibility() -> void:
	if not is_invincible:
		is_invincible = true
		#char_collision.disabled = true  # Disable collision
		invincibility_timer.start() 
		print("Invincibility activated!")
		
		
	
	
	
		

# Play the damage animation and apply knockback
func play_damage_animation() -> void:
	if not is_invincible:  # Only start invincibility if not already invincible
		if facing_right == true:
			velocity.x = -DAMAGE_KNOCKBACK
		else:
			velocity.x = DAMAGE_KNOCKBACK
		
		is_damaged = true
		invincibility()  # Activate invincibility when taking damage
		animated_sprite.play("damaged")  # Play the damaged animation


func die():
	if not is_dead:
		is_dead = true
		velocity = Vector2.ZERO #Stop player movement
		animated_sprite.play("death") #Death animation
		print("Player 1 has died!")
		

	
func _physics_process(delta: float) -> void:
	if is_dead:
		return #Do nothing, player died!
		
	if GameManager.player2_hits == true:

		
		play_damage_animation()
		is_damaged = true
		health -= 1
		print(health)
		GameManager.player2_hits = false

		
	if health <= 0:
		die()
		return # Return early to stop other processes
	
	# Disable movement if the player is damaged
	#if is_damaged:
		#return # Do nothing, player is damaged!
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player1_jump") and is_on_floor():
		if is_attacking == true:
			is_attacking = false
			animated_sprite.stop()
		velocity.y = JUMP_VELOCITY

	# Skip movement if attacking
	if is_attacking:
		# Only handle attack frame logic when attacking
		# Check current frame of attack animation and enable/disable sword collision
		if animated_sprite.animation == "attack": #fix
			attack_frame = animated_sprite.frame
			
			# Enable sword collision on frames 3 and 4
			if attack_frame == 3 or attack_frame == 4:
				sword_collision.disabled = false
			else:
				sword_collision.disabled = true
				
		move_and_slide()
		return # Return early to block movement when attacking
		
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("player1_move_left", "player1_move_right")
	
	#Flip the Sprite
	if direction > 0:
		facing_right = true
		animated_sprite.flip_h = false
		sword_collision.position.x = abs(sword_collision.position.x) # Move sword collider to the right side
	elif direction < 0:
		facing_right = false
		animated_sprite.flip_h = true
		sword_collision.position.x = -abs(sword_collision.position.x) # Move sword collider to the left side
		
		#Play animations
	if is_on_floor():
		if direction == 0 and not is_attacking and not is_damaged:
			animated_sprite.play("idle_2" if health == 2 else "idle_1" if health == 1 else "idle")
		elif direction > 0 or direction < 0 and not is_attacking and not is_damaged:
			animated_sprite.play("run_2" if health == 2 else "run_1" if health == 1 else "run")
	else:
		if not is_invincible:
			animated_sprite.play("jump_2" if health == 2 else "jump_1" if health == 1 else "jump")
		
	#Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	if Input.is_action_just_pressed("player1_attack"):
		attack()

	
func player1():
	pass

		
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false # Reset attack state after animation completes
		sword_collision.disabled = true # Disable sword collision after attack
	if animated_sprite.animation == "death":
		queue_free()


func _on_area_2d_body_entered(body):
	if body.has_method("player2"):
		GameManager.player1_hits = true
		print("hit")


func _on_invincibility_timer_timeout():
	if not is_dead:
		is_invincible = false
		#char_collision.disabled = false  # Enable collision
		animated_sprite.stop()  # Stop the damage animation when invincibility ends
		print("Invincibility ended!")
	
		# Reset the damage flag
		is_damaged = false
	
# Reset animation to idle, run, or jump depending on movement and health
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle_2" if health == 2 else "idle_1" if health == 1 else "idle")  # Idle based on health
		else:
			animated_sprite.play("run_2" if health == 2 else "run_1" if health == 1 else "run")  # Run based on health
	else:
		animated_sprite.play("jump_2" if health == 2 else "jump_1" if health == 1 else "jump")  # Jump based on health
