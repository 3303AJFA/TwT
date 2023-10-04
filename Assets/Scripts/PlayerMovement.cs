using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement Variables")]
    [SerializeField] private float speed;
    [SerializeField] private Rigidbody rb;
    private float _maxSmoothSpeed;
    private PlayerInput _playerInput;

    [Header("Dash Variables")]
    [SerializeField] private float dashPower;
    [SerializeField] private float dashTime;
    [SerializeField] private float dashCooldown;
    private bool _isDashing;
    private float _lastDashTime;
    
    private void Awake()
    {
        rb = this.GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        MovePlayer();
    }

    private bool CanDash()
    {
        return Time.time >= _lastDashTime + dashCooldown;
    }
    
    public void Dash(InputAction.CallbackContext context)
    {
        if (context.performed && !_isDashing && CanDash())
            StartCoroutine(PerformDash());
    }
    
    private void MovePlayer()
    {
        float moveInputHorizontal = Input.GetAxis("Horizontal");
        float moveInputVertical = Input.GetAxis("Vertical");
        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 cameraRight = Camera.main.transform.right;
            
        cameraForward.y = 0;
        cameraRight.y = 0;
            
        Vector3 movement = cameraRight * moveInputHorizontal + cameraForward * moveInputVertical;
        if (movement.magnitude > 1)
            movement.Normalize();
            
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
        _isDashing = true;
        float originalSpeed = speed;
        
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
