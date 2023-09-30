using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;
    
    [SerializeField] private float smoothSpeed;
    [SerializeField] private float movementTime;
    [SerializeField] private float rotationAmount;

    [SerializeField] private Vector3 offset;
    
    void FixedUpdate()
    {
        float rotateInput = Input.GetAxis("RotateCamera");

        RotateCamera(rotateInput);
        HandleMovementInput();
        
        Vector3 desiredPosition = target.position + offset;
        transform.position = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed);
        
    }

    private void RotateCamera(float rotationInput)
    {
        transform.RotateAround(target.position, Vector3.up, rotationInput * rotationAmount * Time.deltaTime);
    }
    
    private void HandleMovementInput()
    {
        transform.position = Vector3.Lerp(transform.position, offset, Time.deltaTime * movementTime);
        /*transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * movementTime);*/
    }
    

}