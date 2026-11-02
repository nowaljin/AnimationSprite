extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0

@onready var sprite = $AnimatedSprite2D

var _jump_was_pressed = false
var _attack_was_pressed = false
var _is_attacking = false

func _ready():
    sprite.play("idle_e")

func _physics_process(delta):
    # Gravity
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    
    # Horizontal movement (A/D)
    var dir = 0.0
    if Input.is_action_pressed("move_left"):
        dir -= 1.0
    if Input.is_action_pressed("move_right"):
        dir += 1.0
    velocity.x = dir * SPEED
    
    # Jump (Space) - track previous state
    var jump_pressed = Input.is_action_pressed("jump")
    if jump_pressed and not _jump_was_pressed and is_on_floor():
        velocity.y = JUMP_VELOCITY
        sprite.play("jump_e")
    _jump_was_pressed = jump_pressed
    
    # Attack (Mouse left click)
    var attack_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
    if attack_pressed and not _is_attacking:
        _is_attacking = true
        sprite.play("attack_e")
    
    # Check if attack animation finished
    if _is_attacking and sprite.animation == "attack_e":
        if sprite.frame >= sprite.sprite_frames.get_frame_count("attack_e") - 1:
            _is_attacking = false
            _attack_was_pressed = false
    
    # Crouch (Ctrl)
    var is_crouching = Input.is_action_pressed("crouch")
    
    # Flip sprite
    if dir > 0:
        sprite.flip_h = false
    elif dir < 0:
        sprite.flip_h = true
    
    move_and_slide()
    
    # Animation (only if not attacking or crouching)
    if is_crouching:
        if sprite.animation != "crouch_e":
            sprite.play("crouch_e")
    elif _is_attacking:
        if sprite.animation != "attack_e":
            sprite.play("attack_e")
    else:
        if is_on_floor():
            if abs(dir) > 0.1:
                if sprite.animation != "run_e":
                    sprite.play("run_e")
            else:
                if sprite.animation != "idle_e":
                    sprite.play("idle_e")
        else:
            if velocity.y < 0:
                if sprite.animation != "jump_e":
                    sprite.play("jump_e")
            else:
                if sprite.animation != "fall_e":
                    sprite.play("fall_e")
