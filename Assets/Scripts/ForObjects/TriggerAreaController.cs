using UnityEngine;

public class TriggerAreaController : MonoBehaviour
{
    private ActionController _actionController;
    private GameObject _player;

    [SerializeField] private Transform holdParent;
    
    private float _moveForce = 150;

    [HideInInspector] public bool door;
    

    private void Start()
    {
        _player = GameObject.Find("Player");
        _actionController = _player.GetComponent<ActionController>();
    }

    private void Update()
    {
        if (door && holdParent.childCount == 0)
        {
            door = false;
            Debug.Log("door: close");
        }
    }

    /*private void OnTriggerEnter(Collider cylinderCollider)
    {
        if (cylinderCollider.CompareTag("Interactive") && _actionController.heldObject != null)
        {
            door = true;
            //Debug.Log("door: open");
        } 
        else if (cylinderCollider.CompareTag("Clone"))
        {
            door = true;
            Debug.Log("door: open");
        }
    }*/

    private void OnTriggerStay(Collider cylinderCollider)
    {
        if (cylinderCollider.CompareTag("Interactive") && _actionController.heldObject == null)
        {
            Rigidbody objectRig = cylinderCollider.gameObject.GetComponent<Rigidbody>();
            objectRig.useGravity = false;
            objectRig.drag = 10;
            
            objectRig.transform.parent = holdParent;
            
            door = true;
            
            if (Vector3.Distance(objectRig.transform.position, holdParent.position) > 0.1f)
            {
                Vector3 moveDirection = (holdParent.position - objectRig.transform.position);
                objectRig.GetComponent<Rigidbody>().AddForce(moveDirection * _moveForce);
            }
        } 
        else if (cylinderCollider.CompareTag("Clone"))
        {
            Rigidbody objectRig = cylinderCollider.gameObject.GetComponent<Rigidbody>();
            objectRig.useGravity = false;
            objectRig.drag = 10;
            
            door = true;
            
            objectRig.transform.parent = holdParent;
            
            if (Vector3.Distance(objectRig.transform.position, holdParent.position) > 0.1f)
            {
                Vector3 moveDirection = (holdParent.position - objectRig.transform.position);
                objectRig.GetComponent<Rigidbody>().AddForce(moveDirection * _moveForce);
            }
        }
    }
    
    private void OnTriggerExit(Collider cylinderCollider)
    {
        if (cylinderCollider.CompareTag("Interactive") && _actionController.heldObject != null)
        {
            //Rigidbody objectRig = cylinderCollider.gameObject.GetComponent<Rigidbody>();
            //objectRig.useGravity = true;
            //objectRig.drag = 1;
            
            //objectRig.transform.parent = null;
            
            door = false;
            Debug.Log("door: close");
        } 
    }
}
