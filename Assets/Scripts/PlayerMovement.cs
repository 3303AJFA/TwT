using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    private LookController _lookController;
    [SerializeField] private PlayerAnimations _playerAnimations;
    
    [Header("Movement Variables")]
    [SerializeField] private float speed;
    private Rigidbody rb;
    public Vector3 mouseDirection = new Vector3(0,0,0);
    private Vector3 dir;
    private PlayerInput _playerInput;
    private float _maxSmoothSpeed;
    private float originalSpeed;
    private Vector3 _movement;
    private Vector3 _movementInput;
    private bool _isWalk;
    private Camera mainCamera;
    private Vector3 cameraForward;
    private Vector3 cameraRight;
    private Vector3 lastMovementDirection;

    [Header("Dash Variables")]
    [SerializeField] private float dashSpeed;
    [SerializeField] private float dashTime;
    [SerializeField] private float dashCooldown;
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
        cameraForward = new Vector3(mainCamera.transform.forward.x,0f,mainCamera.transform.forward.z);
        cameraRight = mainCamera.transform.right;

        float angle = Vector3.SignedAngle(this.transform.forward,cameraForward, Vector3.up)*-1f-90f;

        dir = new Vector3(Mathf.Cos(angle*Mathf.PI/-180),0f,Mathf.Sin(angle*Mathf.PI/-180));

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
        
        if (!_isDashing)
        {
            if (_movement.magnitude > 0)
                lastMovementDirection = _movement.normalized;

            MovePlayer();
        }       
    }   
    private bool CanDash()
    {
        return Time.time >= _lastDashTime + dashCooldown;
    }
    
    public void Dash(InputAction.CallbackContext context)
    {
        if ((context.performed && !_isDashing && CanDash()) && lastMovementDirection != Vector3.zero)
        {
            //Debug.Log("Dash!!!");
            StartCoroutine(PerformDash());
        }
    }
    
    private void MovePlayer()
    {
        rb.MovePosition(rb.position + _movement * (speed * Time.fixedDeltaTime));
    }

    IEnumerator PerformDash()
    {
        _lastDashTime = Time.fixedTime;
        Vector3 dashDirection = lastMovementDirection.normalized;
        
        _isDashing = true;
        
        while (Time.fixedTime < _lastDashTime + dashTime)
        {
            rb.MovePosition(transform.position + dashDirection * dashSpeed * Time.fixedDeltaTime);
            yield return null;
        }
        
        _isDashing = false;
        _lastDashTime = Time.fixedTime;
    }
}
