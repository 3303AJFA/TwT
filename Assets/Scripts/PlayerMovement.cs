using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    private PlayerAnimations _playerAnimations;
    
    [Header("Movement Variables")]
    [SerializeField] private float speed;
    [SerializeField] private Rigidbody rb;
    private float _maxSmoothSpeed;
    private Vector3 _movement;
    private Vector3 _movementInput;
    private Vector3 _lastMovementDirection;
    private PlayerInput _playerInput;
    private bool _isWalk;
    private float originalSpeed;

    [Header("Dash Variables")]
    [SerializeField] private float dashPower;
    [SerializeField] private float dashTime;
    [SerializeField] private float dashCooldown;
    private bool _isDashing;
    private float _lastDashTime;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        _playerAnimations = GetComponent<PlayerAnimations>();
    }

    private void FixedUpdate()
    {
        _movementInput.x = Input.GetAxis("Horizontal");
        _movementInput.z = Input.GetAxis("Vertical");
        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 cameraRight = Camera.main.transform.right;

        if ((_movementInput.x == 0 && _movementInput.z == 0) && _movement.x != 0 || _movement.z != 0)
        {
            _lastMovementDirection = _movement;
        }
        
        cameraForward.y = 0;
        cameraRight.y = 0;
            
        _movement = cameraRight * _movementInput.x + cameraForward * _movementInput.z;
        if (_movement.magnitude > 1)
            _movement.Normalize();
        
        _playerAnimations.IdleAnimation(_lastMovementDirection);
        _playerAnimations.WalkAnimation(_movement);
        _playerAnimations.DashAnimation(_movement,_isDashing); 
        
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
        rb.MovePosition(transform.position + movement * (speed * Time.fixedDeltaTime));
            
        if (movement.magnitude >= 0.1f)
        {
            float angle = Mathf.Atan2(movement.x, movement.z) * Mathf.Rad2Deg; 
            float smooth = Mathf.SmoothDampAngle(transform.eulerAngles.y, angle, ref _maxSmoothSpeed, Time.fixedDeltaTime);

            transform.rotation = Quaternion.Euler(0, smooth, 0);
        }
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
