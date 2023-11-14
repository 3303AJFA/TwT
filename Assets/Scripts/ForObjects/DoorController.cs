using UnityEngine;

public class DoorController : MonoBehaviour
{
    [SerializeField]private TriggerAreaController triggerAreaController;
    private Vector3 _originalPosition;
    private float _maximumDoorTranslate = 0.3f;
    private float _openDoorStep = 10f;
    private bool isDoorStop;
    

    void Start()
    {
        _originalPosition = transform.position;
    }
    
    // Update is called once per frame
    void Update()
    {
        if (triggerAreaController.door == true && _originalPosition.y < _openDoorStep && isDoorStop == false)
        {
            transform.Translate(Vector3.up * _maximumDoorTranslate * Time.deltaTime);
            Debug.Log(transform.position + " " + _originalPosition);
            isDoorStop = false;
        }
        else if ((triggerAreaController.door == false && transform.position.y > _originalPosition.y) && isDoorStop == false)
        {
            transform.Translate(Vector3.down * _maximumDoorTranslate * Time.deltaTime);
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
