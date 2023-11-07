using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private PlayerController _playerController;
    private Rigidbody _rb;
    private bool isOnIce = false;
    private float friction = 1.0f;
    private float iceFriction = 1.2f;
    
    void Start()
    {
        _playerController = GetComponent<PlayerController>();
        _rb = GetComponent<Rigidbody>();
    }
    
    public void MovePlayer()
    {
        Vector3 movement = _playerController.movement * (_playerController.speed * Time.fixedDeltaTime);
        if (isOnIce)
        {
            movement *= iceFriction;
            _rb.AddForce(movement, ForceMode.VelocityChange);
        }
        else
        {
            movement *= friction;
            _rb.MovePosition(_rb.position + movement);
        }
    }
    
    private void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Ice"))
        {
            isOnIce = true;
            friction = iceFriction;
        }
    }
    
    private void OnCollisionExit(Collision other)
    {
        if (other.gameObject.CompareTag("Ice"))
        {
            isOnIce = false;
            friction = 1.0f;
            print("left ice");
        }
    }
}