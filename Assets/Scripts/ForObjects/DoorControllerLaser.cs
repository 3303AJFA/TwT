using UnityEngine;
using UnityEngine.Events;

public class DoorControllerLaser : MonoBehaviour
{
    public SaveAfterDoor saveAfterDoor;
    [SerializeField] private string id;
    private Animator animator;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }
    
    [SerializeField]private LaserReciever laserReciever;
    private Vector3 _originalPosition;
    private Vector3 _savePosition;
    private float _maximumDoorTranslate = 0.8f;
    private float _openDoorStep;
    private float _openDoorY = 2f;
    private bool isDoorStop;
    private bool uploaded = false;
    private bool _doorOpened;

    [SerializeField] private UnityEvent openDoor;
    

    void Start()
    {
        _originalPosition = transform.position;
        _openDoorStep = _originalPosition.y + _openDoorY;
        animator = GameObject.FindGameObjectWithTag("FoundSolutionPanel").GetComponent<Animator>();
    }
    
    // Update is called once per frame
    void Update()
    {
        if (_savePosition != Vector3.zero && !uploaded)
        {
            transform.position = _savePosition;
            uploaded = true;
        }
        
        if ((laserReciever.door && transform.position.y < _openDoorStep) && !isDoorStop)
        {
            transform.Translate(Vector3.forward * _maximumDoorTranslate * Time.deltaTime); 
            //Debug.Log(transform.position + " " + _originalPosition + " " + _openDoorStep);
            isDoorStop = false;
            
            if (!_doorOpened)
            {
                openDoor.Invoke();
                _doorOpened = true;
            }
        }
        else if ((!laserReciever.door && transform.position.y > _originalPosition.y) && !isDoorStop && !uploaded)
        {
            transform.Translate(Vector3.back * _maximumDoorTranslate * Time.deltaTime);
            //Debug.Log(transform.position + " " + _originalPosition);
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

    public void SaveData(GameData data)
    {
        if (saveAfterDoor.isSaved && this != null)
        {
            if (data.doorPositions.ContainsKey(id))
            {
                data.doorPositions.Remove(id);
            }
            
            data.doorPositions.Add(id, transform.position);
        }
    }
}
