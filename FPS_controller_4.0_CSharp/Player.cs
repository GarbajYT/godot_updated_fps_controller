using Godot;

public class Player : KinematicBody{
    public const float GRAVITY = 20;
    public const float MOVE_SPEED = 7;
    public const float JUMP = 10;
    public const float MOUSE_SENS = 0.1f;
    public const float GROUND_ACCEL = 15;
    public const float AIR_ACCEL = 7;

    private Vector3 m_snap, m_gravityVel, m_direction, m_velocity;

    private Spatial m_head;
    private Camera m_camera;
    private float m_accel;    

    public override void _Ready() {
        Input.SetMouseMode(Input.MouseMode.Captured); // Hide the cursor but keep tracking the motion.

        m_head = GetNode<Spatial>("Head");
        m_camera = m_head.GetChild<Camera>(0);
    }

    public override void _Process(float delta){
        MoveCamera(delta);
    }

    public override void _PhysicsProcess(float delta) {
        CalculateDirection();
        CalculateVelocityAndMove(delta);
    }

    public override void _Input(InputEvent ev) {
        if(ev is InputEventMouseMotion motion) {
            RotateY(Mathf.Deg2Rad(-motion.Relative.x * MOUSE_SENS)); // Rotate the whole player on the Y axis.

            //  Don't let it overflow.
            Vector3 rot = RotationDegrees;
            if(rot.y >= 360){
                rot.y -= 360;
            }
            
            if(rot.y <= -360){
                rot.y += 360;
            }
            RotationDegrees = rot;

            m_head.RotateX(Mathf.Deg2Rad(-motion.Relative.y * MOUSE_SENS)); // Rotate the head on the X axis.

            Vector3 headRot = m_head.RotationDegrees;
            headRot.x = Mathf.Clamp(headRot.x, -89, 89); // Limit the head rotation.
            m_head.RotationDegrees = headRot;
        }    
    }

    private void CalculateDirection() {
        // ? Is it better to create new object than setting its values to 0?
        m_direction = new Vector3();

        Vector3 forward = GlobalTransform.basis.z;
        Vector3 right = GlobalTransform.basis.x;

        if(Input.IsActionPressed("player_move_right"))      m_direction += right;
        if(Input.IsActionPressed("player_move_left"))       m_direction -= right;
        if(Input.IsActionPressed("player_move_forward"))    m_direction -= forward;
        if(Input.IsActionPressed("player_move_backward"))   m_direction += forward;

        // Prevent the player from walking faster when walking diagonally.
        m_direction = m_direction.Normalized();
    }

    private void CalculateVelocityAndMove(float delta) {
        if(IsOnFloor()){
            if(Input.IsActionJustPressed("player_jump")){
                m_snap = Vector3.Zero;
                m_gravityVel = new Vector3(0, JUMP, 0);
            }else{
                m_snap = -GetFloorNormal();
                m_gravityVel = Vector3.Zero;
            }
        } else{
            m_accel = AIR_ACCEL;
            m_snap = Vector3.Down;
            m_gravityVel += new Vector3(0, -GRAVITY * delta, 0); 
        }

        m_velocity = m_velocity.LinearInterpolate(m_direction * MOVE_SPEED, m_accel * delta);
        MoveAndSlideWithSnap(m_velocity + m_gravityVel, m_snap, Vector3.Up);
    }

    private void MoveCamera(float delta){
        float fraction = Engine.GetPhysicsInterpolationFraction();
        if(Engine.GetFramesPerSecond() > Engine.IterationsPerSecond){
            m_camera.SetAsToplevel(true);

            Transform t = m_camera.GlobalTransform;
            t.origin = t.origin.LinearInterpolate(m_head.GlobalTransform.origin, fraction);
            m_camera.GlobalTransform = t;

            m_camera.Rotation = new Vector3(m_head.Rotation.x, Rotation.y, m_camera.Rotation.z);
        }else{
            m_camera.SetAsToplevel(false);
            m_camera.GlobalTransform = m_head.GlobalTransform;
        }
    }
}
