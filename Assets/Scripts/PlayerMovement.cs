using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField]
    private float speed = 10.0f;
    [SerializeField]
    private float maxSmoothSpeed;
    [SerializeField]
    private Rigidbody rb;
    private Vector3 movement;
    

    private void Awake()
    {
        rb = this.GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        HandleMovement(movement);
    }

    private void Update()
    {
        movement = new Vector3(Input.GetAxis("Horizontal"), 0f, Input.GetAxis("Vertical"));
    }


    private void HandleMovement(Vector3 direction)
    {
        rb.MovePosition(transform.position + direction * speed * Time.deltaTime);

        if (direction.magnitude >= 0.1f)
        {
            float Angle = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg;
            float Smooth = Mathf.SmoothDampAngle(transform.eulerAngles.y, Angle, ref maxSmoothSpeed, Time.deltaTime);

            transform.rotation = Quaternion.Euler(0, Smooth, 0);
        }
    }
}
