using UnityEngine;

public class BarrierNForPlayerController : MonoBehaviour
{
    private ActionController _actionController;
    private GameObject _player;
    
    private void Start()
    {
        _player = GameObject.Find("Player");
        _actionController = _player.GetComponent<ActionController>();
    }
    
    private void OnCollisionEnter(Collision other)
    {
        if (_actionController.heldObject != null && other.collider.CompareTag("Player"))
        {
            _actionController.DropObject();
        } 
    }
}
