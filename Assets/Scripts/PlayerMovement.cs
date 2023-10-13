using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private PlayerController _playerController;

    void Start()
    {
        _playerController = GetComponent<PlayerController>();
    }
    
    public void MovePlayer()
    {
        _playerController.rb.MovePosition(_playerController.rb.position + _playerController.movement * (_playerController.speed * Time.fixedDeltaTime));
    }
}
