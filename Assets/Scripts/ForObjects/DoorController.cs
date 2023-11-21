using UnityEngine;

public class DoorController : MonoBehaviour
{
    [SerializeField]private TriggerAreaController triggerAreaController;
    private Vector3 _originalPosition;
    private float _maximumDoorTranslate = 0.8f;
    private float _openDoorStep;
    private float _openDoorY = 2f;
    private bool isDoorStop;
    

    void Start()
    {
        _originalPosition = transform.position;
        _openDoorStep = _originalPosition.y + _openDoorY;
    }
    
    // Update is called once per frame
    void Update()
    {
        if ((triggerAreaController.door == true && transform.position.y < _openDoorStep) && isDoorStop == false)
        {
            transform.Translate(Vector3.forward * _maximumDoorTranslate * Time.deltaTime);
            Debug.Log(transform.position + " " + _originalPosition + " " + _openDoorStep);
            isDoorStop = false;

        }
        else if ((triggerAreaController.door == false && transform.position.y > _originalPosition.y) && isDoorStop == false)
        {
            transform.Translate(Vector3.back * _maximumDoorTranslate * Time.deltaTime);
            Debug.Log(transform.position + " " + _originalPosition);
            isDoorStop = false;
        }
    }

    private void OnCollisionEnter(Collision other)
    {
        if (other.collider.CompareTag("Interactive"))
        {
            isDoorStop = true;
            
        }
    }
    
    private void OnCollisionExit(Collision other)
    {
        if (other.collider.CompareTag("Interactive"))
        {
            isDoorStop = false;
        }
    }
}
