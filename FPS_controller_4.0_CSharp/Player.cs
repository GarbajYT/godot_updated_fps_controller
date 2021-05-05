using Godot;
using System.Collections.Generic;

public class Player : KinematicBody
{
    Dictionary<string, int> accel_type = new Dictionary<string, int>();

    Spatial head;
    Camera camera;

    float speed = 7f;
    float gravity = 20f;
    float jump = 10f;
    float cam_accel = 40f;
    float mouse_sense = 0.1f;

    Vector3 snap;
    Vector3 direction = new Vector3();
    Vector3 velocity = new Vector3();
    Vector3 gravity_vec = new Vector3();
    Vector3 movement = new Vector3();

    int accel;

    public override void _Ready()
    {
        accel_type.Add("default", 40);
        accel_type.Add("air", 1);
        accel = accel_type["default"];
        head = GetNode<Spatial>("Head");
        camera = GetNode<Spatial>("Head").GetChild<Camera>(0);

        Input.SetMouseMode(Input.MouseMode.Captured);
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouseMotion mouseMotion) {
            RotateY(Mathf.Deg2Rad(-mouseMotion.Relative.x * mouse_sense));
            head.RotateX(Mathf.Deg2Rad(-mouseMotion.Relative.y * mouse_sense));
            Vector3 rotDeg = head.RotationDegrees;
            rotDeg.x = Mathf.Clamp(rotDeg.x, -89f, 89f);
            head.RotationDegrees = rotDeg;
        }
    }

    public override void _Process(float delta)
    {
        if (Engine.GetFramesPerSecond() > Engine.IterationsPerSecond) {
            camera.SetAsToplevel(true);

            Vector3 Gtrans = head.GlobalTransform.origin;
            camera.GlobalTransform.origin.LinearInterpolate(Gtrans, cam_accel * delta);

            Vector3 camRot = camera.Rotation;
            camRot.y = Rotation.y;
            camRot.x = head.Rotation.x;
            camera.Rotation = camRot;
        } else {
            camera.SetAsToplevel(false);
            camera.GlobalTransform = head.GlobalTransform;
        }
    }

    public override void _PhysicsProcess(float delta)
    {
        direction = Vector3.Zero;
        var h_rot = GlobalTransform.basis.GetEuler().y;
	    var f_input = Input.GetActionStrength("move_backward") - Input.GetActionStrength("move_forward");
	    var h_input = Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left");
	    direction = new Vector3(h_input, 0, f_input).Rotated(Vector3.Up, h_rot).Normalized();

        if (IsOnFloor()) {
            snap = -GetFloorNormal();
		    accel = accel_type["default"];
		    gravity_vec = Vector3.Zero;
        } else {
            snap = Vector3.Down;
		    accel = accel_type["air"];
		    gravity_vec += Vector3.Down * gravity * delta;
        }

        if (Input.IsActionJustPressed("jump") && IsOnFloor()) {
            snap = Vector3.Zero;
		    gravity_vec = Vector3.Up * jump;
        }

        velocity = velocity.LinearInterpolate(direction * speed, accel * delta);
	    movement = velocity + gravity_vec;
	
	    MoveAndSlideWithSnap(movement, snap, Vector3.Up);

    }

}
