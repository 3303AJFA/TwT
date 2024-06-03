using UnityEngine;
using UnityEngine.InputSystem;

public class CloneController : MonoBehaviour
{
    [SerializeField]private GameObject playerClone;
    [SerializeField]private Rigidbody rbPlayer;

    private Vector3 _mousePosition;
    private Vector3 _spawnPosition;
    private GameObject _clone;
    [SerializeField] private LayerMask layerMask;
    
    public static bool isClone = false;

    public void OnLeftMouseButton(InputAction.CallbackContext context)
    {
        if (context.performed && _clone == null && !OpenMenuUI.GameIsPaused)
        {
            _mousePosition = Input.mousePosition;
            
            Vector3 viewportPosition = Camera.main.ScreenToViewportPoint(_mousePosition);
            
            Ray ray = Camera.main.ViewportPointToRay(viewportPosition);
            RaycastHit hit;
            
            if (Physics.Raycast(ray, out hit, Mathf.Infinity, layerMask))
            {
                Debug.Log(hit.collider);
                _spawnPosition = hit.point;
            }
            
            _clone = Instantiate(playerClone, _spawnPosition, rbPlayer.transform.rotation);
            _clone.tag = "Clone";

            isClone = true;
        }
    }
    
    public void OnRightMouseButton(InputAction.CallbackContext context)
    {
        if (context.performed && _clone != null && !OpenMenuUI.GameIsPaused)
        {
            Destroy(_clone);
            isClone = false;
        }
    }
}
