using Unity.VisualScripting;
using UnityEngine;

public class DoorController : MonoBehaviour, IDataPersistence
{
    public SaveAfterDoor saveAfterDoor;
    [SerializeField] private string id;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }
    
    [SerializeField]private TriggerAreaController triggerAreaController;
    private Vector3 _originalPosition;
    private Vector3 _savePosition;
    private float _maximumDoorTranslate = 0.8f;
    private float _openDoorStep;
    private float _openDoorY = 2f;
    private bool isDoorStop;
    private bool uploaded = false;
    

    void Start()
    {
        _originalPosition = transform.position;
        _openDoorStep = _originalPosition.y + _openDoorY;
    }
    
    // Update is called once per frame
    void Update()
    {
        if (_savePosition != Vector3.zero && !uploaded)
        {
            transform.position = _savePosition;
            uploaded = true;
        }
        
        if ((triggerAreaController.door && transform.position.y < _openDoorStep) && !isDoorStop)
        {
            transform.Translate(Vector3.forward * _maximumDoorTranslate * Time.deltaTime);
            Debug.Log(transform.position + " " + _originalPosition + " " + _openDoorStep);
            isDoorStop = false;
        }
        else if ((!triggerAreaController.door && transform.position.y > _originalPosition.y) && !isDoorStop && !uploaded)
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

    public void LoadData(GameData data)
    {
        data.doorPositions.TryGetValue(id, out _savePosition);
    }

    public void SaveData(ref GameData data)
    {
        if (saveAfterDoor.isSaved)
        {
            if (data.doorPositions.ContainsKey(id))
            {
                data.doorPositions.Remove(id);
            }
            
            data.doorPositions.Add(id, transform.position);
        }
    }
}
