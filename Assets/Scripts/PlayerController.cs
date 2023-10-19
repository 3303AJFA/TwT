using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private LookController _lookController;
    private PlayerMovement _playerMovement;
    [HideInInspector] public PlayerAnimations playerAnimations;
    
    [Header("Movement Variables")]
    public float speed;
    public Vector3 mouseDirection = new Vector3(0,0,0);
    private PlayerInput _playerInput;
    private float _maxSmoothSpeed;
    private float _originalSpeed;
    private Vector3 _movementInput;
    private bool _isWalk;
    private Camera _mainCamera;
    private Vector3 _cameraForward;
    private Vector3 _cameraRight;
    [HideInInspector] public bool isDashing;
    [HideInInspector] public Rigidbody rb;
    [HideInInspector] public Vector3 dir;
    [HideInInspector] public Vector3 movement;
    [HideInInspector] public Vector3 lastMovementDirection;

    private void Start()
    {   
        _mainCamera = Camera.main; 
        rb = GetComponent<Rigidbody>();
        _lookController = GetComponent<LookController>();
        playerAnimations = GetComponent<PlayerAnimations>();
        _playerMovement = GetComponent<PlayerMovement>();
    }

    private void Update()
    {
        _movementInput.x = Input.GetAxis("Horizontal");
        _movementInput.z = Input.GetAxis("Vertical");
        
        _lookController.Aim();
    }
    
    private void FixedUpdate()
    {
        //Debug.DrawRay(Camera.main.transform.position, cameraForward*500f, Color.red, 0.0f, true);
        _cameraRight = _mainCamera.transform.right;
        _cameraRight.y = 0;
        
        movement = _cameraRight * _movementInput.x + _cameraForward * _movementInput.z;

        if(isDashing){
            playerAnimations.DashAnimation(FrontDir2Anim(movement),isDashing);
        }
        else if(movement.x == 0 && movement.z == 0)
        { 
            playerAnimations.IdleAnimation(Sight2Anim());
        }
        else
        {
            playerAnimations.WalkAnimation(Sight2Anim());
        }
        if (movement.magnitude > 1)
            movement.Normalize();
        if (!isDashing)
        {
            if (movement.magnitude > 0)
                lastMovementDirection = movement.normalized;

            _playerMovement.MovePlayer();
        }    
    }  
    
    private Vector3 Sight2Anim(){
        _cameraForward = new Vector3(_mainCamera.transform.forward.x,0f,_mainCamera.transform.forward.z);
        
        float angle = Vector3.SignedAngle(this.transform.forward,_cameraForward, Vector3.up)*-1f-90f;
        
        dir = new Vector3(Mathf.Cos(angle*Mathf.PI/-180),0f,Mathf.Sin(angle*Mathf.PI/-180));
        
        return dir;
    }
    
    private Vector3 FrontDir2Anim(Vector3 frontMovement){
        _cameraForward = new Vector3(_mainCamera.transform.forward.x,0f,_mainCamera.transform.forward.z);
        
        float angle = Vector3.SignedAngle(frontMovement,_cameraForward, Vector3.up)*-1f-90f;
        
        dir = new Vector3(Mathf.Cos(angle*Mathf.PI/-180),0f,Mathf.Sin(angle*Mathf.PI/-180));
        
        return dir;
    }
    

    
}
