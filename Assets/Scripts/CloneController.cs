using UnityEngine;
using UnityEngine.InputSystem;

public class CloneController : MonoBehaviour
{
    [SerializeField]private GameObject playerClone;
    [SerializeField]private Rigidbody rbPlayer;
    
    private Transform _cloneTransform;
    private GameObject _clone;
    

    public void OnLeftMouseButton(InputAction.CallbackContext context)
    {
        if (context.performed && _clone == null)
        {
            _clone = Instantiate(playerClone, rbPlayer.transform.position, rbPlayer.transform.rotation,_cloneTransform);
            _clone.tag = "Clone";
        }
    }
    
    public void OnRightMouseButton(InputAction.CallbackContext context)
    {
        if (context.performed && _clone != null)
        {
            Destroy(_clone);
        }
    }
}
