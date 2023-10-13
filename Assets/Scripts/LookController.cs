using UnityEngine;

public class LookController : MonoBehaviour
{
    private PlayerController _playerController;
    private Camera mainCamera;

    [SerializeField] private LayerMask groundMask;

    private void Start() {
        mainCamera = Camera.main;
        _playerController = GetComponent<PlayerController>();
    }

    public void Aim()
    {
        var (success, position) = GetMousePosition();
        if (success)
        {
            var direction = position - transform.position;

            direction.y = 0;
            
            transform.forward = direction;
        }
    }

    private (bool success, Vector3 position) GetMousePosition()
    {
        var ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        
        if (Physics.Raycast(ray, out var hitInfo, Mathf.Infinity, groundMask))
        {
            
            //Debug.Log("The Raycast hit something");
            _playerController.mouseDirection = hitInfo.point;
            return (success: true, position: hitInfo.point);
        }
        else
        {
            //Debug.Log("The Raycast did not hit anything");
            return (success: false, position: Vector3.zero);
        }
    }
}
