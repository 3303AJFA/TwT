using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    private LookController _lookController;
    
    [Header("Movement Variables")]
    [SerializeField] private float speed;
    [SerializeField] private Rigidbody rb;
    [HideInInspector]
    public Vector3 mouseDirection = new Vector3(0,0,0); 
    private PlayerInput _playerInput;
    private float _maxSmoothSpeed;
    private float originalSpeed;
    private Vector3 _movement;
    private Vector3 _movementInput;
    private Vector3 _lastMovementDirection;
    private bool _isWalk;
    private Camera mainCamera;

    [Header("Dash Variables")]
    [SerializeField] private float dashPower;
    [SerializeField] private float dashTime;
    [SerializeField] private float dashCooldown;
    [SerializeField] private PlayerAnimations _playerAnimations;
    private bool _isDashing;
    private float _lastDashTime;

    private void Start()
    {   
        mainCamera = Camera.main;
        rb = GetComponent<Rigidbody>();
        _lookController = GetComponent<LookController>();
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
        Vector3 cameraForward = new Vector3(mainCamera.transform.forward.x,0f,mainCamera.transform.forward.z);
        Vector3 cameraRight = mainCamera.transform.right;

        float angle = Vector3.SignedAngle(this.transform.forward,cameraForward, Vector3.up)*-1f-90f;

        Vector3 dir = new Vector3(Mathf.Cos(angle*Mathf.PI/-180),0f,Mathf.Sin(angle*Mathf.PI/-180));

        if(_movement.x == 0 && _movement.z == 0)
        {
            _playerAnimations.IdleAnimation(dir);
        }
        else
        {
        _playerAnimations.WalkAnimation(dir);
        _playerAnimations.DashAnimation(dir,_isDashing);
        }
        cameraRight.y = 0;
            
        _movement = cameraRight * _movementInput.x + cameraForward * _movementInput.z;
        if (_movement.magnitude > 1)
            _movement.Normalize();
        MovePlayer(_movement);        
    }   
    private bool CanDash()
    {
        return Time.time >= _lastDashTime + dashCooldown;
    }
    
    public void Dash(InputAction.CallbackContext context)
    {
        if (context.performed && !_isDashing && CanDash())
        {
            Debug.Log("Dash!!!");
            _isDashing = true;
            StartCoroutine(PerformDash());
        }
    }
    
    private void MovePlayer(Vector3 movement)
    {
        rb.MovePosition(rb.position + movement * (speed * Time.fixedDeltaTime));

        /*if (movement.magnitude >= 0.1f)
        {
            float angle = Mathf.Atan2(movement.x, movement.z) * Mathf.Rad2Deg;
            float smooth = Mathf.SmoothDampAngle(transform.eulerAngles.y, angle, ref _maxSmoothSpeed, Time.fixedDeltaTime);

            transform.rotation = Quaternion.Euler(0, smooth, 0);
        }*/
    }

    IEnumerator PerformDash()
    {
        _lastDashTime = Time.fixedTime;
        originalSpeed = speed;
        
        while (Time.fixedTime < _lastDashTime + dashTime)
        {
            speed += dashPower * Time.fixedDeltaTime;
            yield return null;
        }

        speed = originalSpeed;
        _isDashing = false;
        _lastDashTime = Time.fixedTime;
    }
}
