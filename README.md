# Exercise 3.2-Tweening and Screen Shake

Exercise for MSCH-C220

This exercise is the next opportunity for you to experiment with juicy features to our brick-breaker game. The exercise will provide you with several more features that should move you towards the implementation of Project 3.

The expectations for this exercise are that you will

 - [ ] Fork and clone this repository
 - [ ] Import the project into Godot
 - [ ] Use Tweening to animate properties of the paddle, the lives indicator, and the ball. Cause the ball to distort as it moves and wobble when it is hit
 - [ ] Use Tweening to animate the entrance and exit of the bricks (including their color and transparency)
 - [ ] Add a bouncing ball to the main menu
 - [ ] Add a Camera2D to the Game scene and introduce screen shake when the ball falls off the screen
 - [ ] Edit the LICENSE and README.md
 - [ ] Commit and push your changes back to GitHub. Turn in the URL of your repository on Canvas.

## Instructions

Fork this repository. When that process has completed, make sure that the top of the repository reads [your username]/Exercise-3-2-Tweening-and-Screen-Shake. *Edit the LICENSE and replace BL-MSCH-C220 with your full name.* Commit your changes.

Press the green "Code" button and select "Open in GitHub Desktop". Allow the browser to open (or install) GitHub Desktop. Once GitHub Desktop has loaded, you should see a window labeled "Clone a Repository" asking you for a Local Path on your computer where the project should be copied. Choose a location; make sure the Local Path ends with "Exercise-3-2-Tweening-and-Screen-Shake" and then press the "Clone" button. GitHub Desktop will now download a copy of the repository to the location you indicated.

Open Godot. In the Project Manager, tap the "Import" button. Tap "Browse" and navigate to the repository folder. Select the project.godot file and tap "Open".

If you run the project, you will see the project where we left off at the end of Exercise 03a. We will now have an opportunity to start making it "juicier".

*I have made a few small adjustments to this exercise's code in anticpation of this exercise. If it seems like I have moved things around a bit, don't worry.*

---

## The Ball

Open `res://Ball/Ball.gd`. Edit the `_on_Ball_body_entered` and add this to the end of that function:
```
    if tween:
        tween.kill()
    tween = create_tween().set_parallel(true)
    $Images/Highlight.modulate.a = 1.0
    tween.tween_property($Images/Highlight, "modulate:a", 0, time_highlight).set_trans(Tween.TRANS_LINEAR)
    $Images/Highlight.scale = Vector2(2.0,2.0)
    tween.tween_property($Images/Highlight, "scale", Vector2(1.0,1.0),time_highlight_size).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
    wobble_direction = linear_velocity.orthogonal().normalized()
    wobble_amplitude = wobble_max
```

I have stubbed out `wobble()` and `distort()` functions (that will ultimately make the ball wobble as it hits something and distort it as it moves faster). The contents of those functions should be as follows:
```
func wobble():
  wobble_period += 1
  if wobble_amplitude > 0:
    var pos = wobble_direction * wobble_amplitude * sin(wobble_period)
    $Images.position = pos
    wobble_amplitude -= decay_wobble
```
```
func distort():
  var direction = Vector2(1 + linear_velocity.length() * distort_effect, 1 - linear_velocity.length() * distort_effect)
  $Images.rotation = linear_velocity.angle()
  $Images.scale = direction
```

## The Indicator

Open `res://UI/HUD.gd`, then edit the script as follows, filling in the breathe function:

```
func breathe():
    indicator_scale = indicator_scale_target if indicator_scale == indicator_scale_start else indicator_scale_start
    indicator_mod = indicator_mod_target if indicator_mod == indicator_mod_start else indicator_mod_start
        
    if tween: tween.kill()
    tween = get_tree().create_tween().set_parallel(true)
    for i in $Indicator_Container.get_children():
        tween.tween_property(i.get_node("Highlight"), "scale", indicator_scale, 0.5)
        tween.tween_property(i.get_node("Highlight"), "modulate:a", indicator_mod, 0.5)
    tween.set_parallel(false)
    tween.tween_callback(self.breathe)
```

## The Paddle

Open `res://Paddle/Paddle.gd`, and then append the following to the end of `hit(_ball)`:
```
    if tween:
      tween.kill()
    tween = create_tween().set_parallel(true)
    $Images/Highlight.modulate.a = 1.0
    tween.tween_property($Images/Highlight, "modulate:a", 0.0, time_highlight)
    $Images/Highlight.scale = Vector2(1.5, 1.5)
    tween.tween_property($Images/Highlight, "scale", Vector2(1.0,1.0), time_highlight_size).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN) 
```

## The Bricks

Open `res://Brick/Brick.gd` and replace line 16 with the following:
```
    position.x = new_position.x
    position.y = -100
    tween = create_tween()
    tween.tween_property(self, "position", new_position, 0.5 + randf()*2).set_trans(Tween.TRANS_BOUNCE)
```

Replace line 36 in `res://Brick/Brick.gd` with the following:
```
  if dying and not $Confetti.emitting and not tween:
```

Then, add the following at the end of the `die()` function:
```
    if tween:
      tween.kill()
    tween = create_tween().set_parallel(true)
    tween.tween_property(self, "position", Vector2(position.x, 1000), time_fall).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
    tween.tween_property(self, "rotation", -PI + randf()*2*PI, time_rotate).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property($ColorRect, "color:a", 0, time_a)
    tween.tween_property($ColorRect, "color:s", 0, time_s)
    tween.tween_property($ColorRect, "color:v", 0, time_v)
```

## Screen Shake

Finally, open `res://Game.tscn`. As a child of the Game node, attach a Camera2D and rename it Camera. *Set the Camera as Enabled = yes and set the Anchor Mode=Fixed TopLeft in the Inspector* Attach the following script (`res://UI/Camera.gd`) to the Camera node (this would be a good script to save in your GitHub Gists for later):
```
extends Camera2D
# Originally developed by Squirrel Eiserloh (https://youtu.be/tu-Qe66AvtY)
# Refined by KidsCanCode (https://kidscancode.org/godot_recipes/2d/screen_shake/)

var decay = 5             # How quickly the shaking stops
var max_offset = Vector2(15, 0)     # Maximum hor/ver shake in pixels.
var max_roll = 0.05           # Maximum rotation in radians (use sparingly).

var trauma = 0.0            # Current shake strength.
var trauma_power = 3          # Trauma exponent. Use [2, 3].
var max_trauma = 4.0
var noise = FastNoiseLite.new()
var noise_y = 0

func _ready():
  randomize()
  noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
  noise.seed = randi()
  noise.frequency = 4.0

func _process(delta):
  if trauma:
    trauma = max(trauma - decay * delta, 0)
    shake()
  
func shake():
  var amount = pow(min(trauma,1.0), trauma_power)
  noise_y += 1
  rotation = max_roll * amount * noise.get_noise_2d(1, noise_y)
  offset.x = max_offset.x * amount * noise.get_noise_2d(2, noise_y)
  offset.y = max_offset.y * amount * noise.get_noise_2d(3, noise_y)
  
func add_trauma(amount):
  trauma = min(trauma + amount, max_trauma)
```

Open `res://Ball/Ball_Container.gd`. Replace `_physics_process` with the following:
```
func _physics_process(_delta):
  if get_child_count() == 0:
    Global.update_lives(-1)
    var camera = get_node_or_null("/root/Game/Camera")
    if camera != null:
      camera.add_trauma(3.0)
    make_ball()
```

---

Test the game and make sure it is working correctly. You should be able to see the bricks randomly fall into their designated location and fall (fade and rotate) off the screen as they are hit. There is lots of new movement: the ball, the paddle, the indicators. When you die, the screen should shake. There should also be an animated ball on the main menu.

Quit Godot. In GitHub desktop, you should now see the updated files listed in the left panel. In the bottom of that panel, type a Summary message (something like "Completes the exercise") and press the "Commit to master" button. On the right side of the top, black panel, you should see a button labeled "Push origin". Press that now.

If you return to and refresh your GitHub repository page, you should now see your updated files with the time when they were changed.

Now edit the README.md file. When you have finished editing, commit your changes, and then turn in the URL of the main repository page (https://github.com/[username]/Exercise-3-2-Tweening-and-Screen-Shake) on Canvas.

The final state of the file should be as follows (replacing my information with yours):
```
# Exercise 3.2-Tweening and Screen Shake

Exercise for MSCH-C220

The second exercise adding "juicy" features to a simple brick-breaker game.

## To play

Move the paddle using the mouse. Help the ball break all the bricks before you run out of time.


## Implementation

Created using [Godot 4.1.1](https://godotengine.org/download)

## References
 * [Juice it or lose it — a talk by Martin Jonasson & Petri Purho](https://www.youtube.com/watch?v=Fy0aCDmgnxg)
 * [Puzzle Pack 2, provided by kenney.nl](https://kenney.nl/assets/puzzle-pack-2)
 * [Open Color open source color scheme](https://yeun.github.io/open-color/)
 * [League Gothic Typeface](https://www.theleagueofmoveabletype.com/league-gothic)
 * [Orbitron Typeface](https://www.theleagueofmoveabletype.com/orbitron)
 

## Future Development

Adding a face, Comet trail, Music and Sound, Shaders, etc.

## Created by 

Jason Francis
```
