using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class ActionController : MonoBehaviour
{
    private PlayerController _playerController;
    
    [SerializeField] private float pickUpRange;
    [SerializeField] private LayerMask interactiveLayerMask;
    [SerializeField] private Transform holdParent;
    [SerializeField] private float moveForce;
    [SerializeField] private float throwForce;
    [SerializeField] private float maxChargeTime;
    [SerializeField] private Image chargeIndicator;

    private float _currentChargeTime = 0f;
    private bool _isCharging = false;
    
    private Vector3 _holdOffset;
    private RaycastHit hit;
    
    [HideInInspector]
    public GameObject heldObject;
    

    private void Start()
    {
        _playerController = GetComponent<PlayerController>();
    }

    void Update()
    {
        if (heldObject != null)
        {
            MoveObject();
        }
        
        if (_isCharging)
        {
            _currentChargeTime += Time.deltaTime; // Обновляем время зарядки
            UpdateChargeIndicator();
        }
        else
        {
            UpdateChargeIndicator();
        }
        
        Debug.DrawRay(transform.position, 2 * (holdParent.position - transform.position), Color.green, pickUpRange);
    }

    public void GrabAndDropAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            if (heldObject == null)
            {
                if (Physics.Raycast(transform.position, 2 * (holdParent.position - transform.position), out hit, pickUpRange, interactiveLayerMask))
                {   
                    if(hit.collider.tag == "Interactive")
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
        if (context.performed && (heldObject != null && !_isCharging))
        {
            StartCharging();
        }
        else if (context.canceled && _isCharging)
        {
            StopCharging();
        }
    }
    
    private void MoveObject()
    {
        if (Vector3.Distance(heldObject.transform.position, holdParent.position) > 0.1f)
        {
            Vector3 moveDirection = (holdParent.position - heldObject.transform.position);
            heldObject.GetComponent<Rigidbody>().AddForce(moveDirection * moveForce);
        }
    }

    private void PickupObject(GameObject pickObject)
    {
        if (pickObject.GetComponent<Rigidbody>())
        {
            Rigidbody objectRig = pickObject.GetComponent<Rigidbody>();
            objectRig.useGravity = false;
            objectRig.drag = 10;
            _playerController.speed /= 2; 
            
            objectRig.transform.parent = holdParent;
            heldObject = pickObject;
        }
    }

    public void DropObject()
    {
            Rigidbody heldRig = heldObject.GetComponent<Rigidbody>();
            heldRig.useGravity = true;
            heldRig.drag = 1;
            _playerController.speed *= 2;
        
            heldObject.transform.parent = null;
            heldObject = null;
    }
    
    private void PushObject()
    {
        if (Physics.Raycast(transform.position, 2 * (holdParent.position - transform.position), out hit, pickUpRange))
        {
            Rigidbody throwRigidbody = hit.transform.gameObject.GetComponent<Rigidbody>();
            if (throwRigidbody != null)
            {
                float finalThrowForce = CalculateThrowForce();
                throwRigidbody.AddForce(transform.forward * finalThrowForce, ForceMode.Impulse);
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
    
    private float CalculateThrowForce()
    {
        return Mathf.Clamp(_currentChargeTime, 0f, maxChargeTime) * throwForce;  // Добавлено: рассчет силы броска на основе зарядки
    }

    private void StartCharging()
    {
        _isCharging = true;
        _currentChargeTime = 0f;
    }

    private void StopCharging()
    {
        _isCharging = false;
        DropObject();
        PushObject();
        _currentChargeTime = 0f;
    }
    
    private void UpdateChargeIndicator()
    {
        // Обновляем UI элемент зарядки (например, изменяем fillAmount для заполнения круга)
        chargeIndicator.fillAmount = _currentChargeTime / maxChargeTime;
    }

}
