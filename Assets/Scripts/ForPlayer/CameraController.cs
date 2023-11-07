using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject target;
    
    [SerializeField] private float smoothSpeed;
    [SerializeField] private float movementTime;
    [SerializeField] private float keyboardRotationAmount;
    [SerializeField] private Vector3 offset;
    
    void FixedUpdate()
    {
        float keyboardRotateInput = Input.GetAxis("RotateCamera");
        RotateCamera(keyboardRotateInput);
        HandleMovementInput();
        
        Vector3 desiredPosition = target.transform.position + offset;
        transform.position = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed);
    }

    private void RotateCamera(float rotationInput)
    {
        transform.RotateAround(target.transform.position, Vector3.up, rotationInput * keyboardRotationAmount * Time.fixedDeltaTime);
    }
    
    private void HandleMovementInput()
    {
        transform.position = Vector3.Lerp(transform.position, offset, Time.fixedDeltaTime * movementTime);
    }
}