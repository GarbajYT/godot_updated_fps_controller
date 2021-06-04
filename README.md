# godot_updated_fps_controller
Updated basic fps and tps controllers for Godot 3.x and 4.0.

Features include:

-basic movement and jumping

-physics interpolation to reduce jitter on high refresh rate monitors

-solves all weird slope sliding/climbing issues 


Suggestions:

-attach FPS.gd to the main node (kinematic body) of FPS.tscn

-attach TPS.gd to the main node (kinematic body) of TPS.tscn

-names for wasd keybindings are "move_forward" "move_backward" "move_left" and "move_right"

-this is just a character controller, I assume you already have a game world set up to test it out on
