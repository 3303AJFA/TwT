using UnityEngine;


public class PlayerMovement : MonoBehaviour
{
    private PlayerController _playerController;

    private float friction = 1.0f;
    void Start()
    {
        _playerController = GetComponent<PlayerController>();
    }
    
 public void MovePlayer()
    {   
    Vector3 movement = _playerController.movement * (_playerController.speed * Time.fixedDeltaTime);
 
    movement *= friction;

    _playerController.rb.MovePosition(_playerController.rb.position + movement);
    }
    private void OnCollisionEnter(Collision other) {
	    if(other.gameObject.CompareTag("Ice")) friction = 1.5f;    
    }
    private void OnCollisionExit(Collision other) {
	    if(other.gameObject.CompareTag("Ice")) friction = 1.0f;    
        if(other.gameObject.CompareTag("Ice")) print("left ice");
    }
}
