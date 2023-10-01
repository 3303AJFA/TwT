using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;
    
    [SerializeField] private float smoothSpeed;
    [SerializeField] private float movementTime;
    [SerializeField] private float keyboardRotationAmount;
    [SerializeField] private float mouseRotationAmount;
    [SerializeField] private Vector3 offset;
    
    void FixedUpdate()
    {
        float keyboardRotateInput = Input.GetAxis("RotateCamera");
        float mouseRotateInput = Input.GetAxis("Mouse X");
        RotateCamera(keyboardRotateInput);
        HandleRotationInput(mouseRotateInput);
        HandleMovementInput();
        
        Vector3 desiredPosition = target.position + offset;
        transform.position = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed);
    }

    private void RotateCamera(float rotationInput)
    {
        transform.RotateAround(target.position, Vector3.up, rotationInput * keyboardRotationAmount * Time.fixedDeltaTime);
    }
    private void HandleRotationInput(float rotationInput)
    {
        if (Input.GetMouseButton(1))
        {
            transform.RotateAround(target.position, Vector3.up, rotationInput * mouseRotationAmount * Time.fixedDeltaTime);
        }
    }
    
    private void HandleMovementInput()
    {
        transform.position = Vector3.Lerp(transform.position, offset, Time.fixedDeltaTime * movementTime);
    }
}