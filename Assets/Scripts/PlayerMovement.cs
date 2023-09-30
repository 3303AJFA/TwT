using System;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    
    [SerializeField]
    private float speed = 10.0f;
    [SerializeField]
    private float maxSmoothSpeed;
    [SerializeField]
    private Rigidbody rb;
    
    private void Awake()
    {
        rb = this.GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        MovePlayer();
    }
    
    private void MovePlayer()
    {
            float moveInputHorizontal = Input.GetAxis("Horizontal");
            float moveInputVertical = Input.GetAxis("Vertical");
            Vector3 cameraForward = Camera.main.transform.forward;
            Vector3 cameraRight = Camera.main.transform.right;
            
            cameraForward.y = 0;
            cameraRight.y = 0;
            cameraForward.Normalize();
            cameraRight.Normalize();
            
            Vector3 movement = cameraRight * moveInputHorizontal + cameraForward * moveInputVertical;
            movement.Normalize();
            
            rb.MovePosition(transform.position + movement * (speed * Time.deltaTime));
            
            if (movement.magnitude >= 0.1f)
            {
                float angle = Mathf.Atan2(movement.x, movement.z) * Mathf.Rad2Deg;
                float smooth = Mathf.SmoothDampAngle(transform.eulerAngles.y, angle, ref maxSmoothSpeed, Time.deltaTime);

                transform.rotation = Quaternion.Euler(0, smooth, 0);
            }
    }
}
