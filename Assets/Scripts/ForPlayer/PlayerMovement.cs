using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private PlayerController _playerController;
    private Rigidbody _rb;
    
    void Start()
    {
        _playerController = GetComponent<PlayerController>();
        _rb = GetComponent<Rigidbody>();
    }
    
    public void MovePlayer()
    {
        Vector3 movement = _playerController.movement * (_playerController.speed * Time.fixedDeltaTime);
        _rb.MovePosition(_rb.position + movement);
    }
}