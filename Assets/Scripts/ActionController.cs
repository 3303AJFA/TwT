using UnityEngine;
using UnityEngine.InputSystem;

public class ActionController : MonoBehaviour
{
    [SerializeField] private float pickUpRange;
    [SerializeField] private Transform holdParent;
    [SerializeField] private float moveForce;
    [SerializeField] private float throwForce;
    private GameObject _heldObject;
    private RaycastHit hit;
    
    private bool _canPush = true;
    
    void Update()
    {
        if (_heldObject != null)
        {
            MoveObject();
        }
    }

    public void GrabAndDropAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            if (_heldObject == null)
            {
                if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, pickUpRange))
                {
                    PickupObject(hit.transform.gameObject);
                }
            }
            else
            {
                DropObject();
            }
        } 
    }

    public void PushAction(InputAction.CallbackContext context)
    {
        if (context.performed && (_heldObject == null && _canPush))
        {
            PushObject();
        }
    }
    
    private void MoveObject()
    {
        if (Vector3.Distance(_heldObject.transform.position, holdParent.position) > 0.1f)
        {
            Vector3 moveDirection = (holdParent.position - _heldObject.transform.position);
            _heldObject.GetComponent<Rigidbody>().AddForce(moveDirection * moveForce);
        }
    }

    private void PickupObject(GameObject pickObject)
    {
        if (pickObject.GetComponent<Rigidbody>())
        {
            Rigidbody objectRig = pickObject.GetComponent<Rigidbody>();
            objectRig.useGravity = false;
            objectRig.drag = 10;
            _canPush = false;
            
            objectRig.transform.parent = holdParent;
            _heldObject = pickObject;
        }
    }

    private void DropObject()
    {
            Rigidbody heldRig = _heldObject.GetComponent<Rigidbody>();
            heldRig.useGravity = true;
            heldRig.drag = 1;
            
        
            _heldObject.transform.parent = null;
            _heldObject = null;
            _canPush = true;
        
    }
    
    private void PushObject()
    {
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, pickUpRange))
        {
            Rigidbody throwRigidbody = hit.transform.gameObject.GetComponent<Rigidbody>();
            if (throwRigidbody != null)
            {
                throwRigidbody.AddForce(transform.forward * throwForce, ForceMode.Impulse);
            }
            else
            {
                Debug.LogWarning("The object hit does not have a Rigidbody component.");
            }
        }
        else
        {
            Debug.LogWarning("No object hit by the Raycast.");
        }
    }
}
