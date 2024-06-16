using UnityEngine;

public class PortalTeleport : MonoBehaviour
{
    public Transform player;
    public Transform otherPortal;
    public GameObject wall;

    private GameObject _teleportedObject;
    private GameObject _cloneObject;
    private bool playerIsOverlapping = false;
    private bool objectIsOverlapping = false;

    private const int MaxClonesLaser = 1;
    private int currentClones;
    private Quaternion rotationOffset;

    private void Start()
    {
        rotationOffset = Quaternion.Inverse(transform.rotation) * otherPortal.transform.rotation;
    }

    private void Update()
    {
        if (playerIsOverlapping)
        {
            TeleportPlayer();
        }
        
        if (objectIsOverlapping)
        {
            TeleportObject();
        }
    }

    private void TeleportPlayer()
    {
        Vector3 portalToPlayer = player.position - transform.position;
        float dotProduct = Vector3.Dot(transform.up, portalToPlayer);

        if (dotProduct < 0f)
        {
            float rotationDiff = -Quaternion.Angle(transform.rotation, otherPortal.rotation);
            rotationDiff += 180;
            player.Rotate(Vector3.up, rotationDiff);

            Vector3 positionOffset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
            player.position = new Vector3(otherPortal.position.x, otherPortal.position.y, otherPortal.position.z)  + positionOffset;

            Debug.Log("Player Teleport");
            playerIsOverlapping = false;
        }
    }
    
    private void TeleportObject()
    {
        if (_teleportedObject == null) return;
        
        Vector3 portalToObject = _teleportedObject.transform.position - transform.position;
        float dotProduct = Vector3.Dot(transform.up, portalToObject);

        if (dotProduct < 0f)
        {
            // 1. Рассчитываем точку выхода
            Vector3 positionOffset = otherPortal.TransformPoint(transform.InverseTransformPoint(_teleportedObject.transform.position));
            
            // 2. Телепортируем объект
            _teleportedObject.transform.position = positionOffset;
            
            // 3. Поворачиваем объект
            _teleportedObject.transform.rotation *= rotationOffset;
            
            Rigidbody rb = _teleportedObject.GetComponent<Rigidbody>();
            if (rb != null)
            {
                Vector3 velocityOffset = otherPortal.TransformDirection(transform.InverseTransformDirection(rb.velocity));
                rb.velocity = velocityOffset;
            }
            
            Debug.Log("Object Teleport");

            objectIsOverlapping = false;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        var m_collider = wall.GetComponentsInChildren<Collider>();
        
        if (other.CompareTag("Player"))
        {
            foreach (var collider in m_collider)
            {
                collider.isTrigger = true;
            }
            
            playerIsOverlapping = true;
        }
        
        if (other.CompareTag("Interactive"))
        {
            foreach (var collider in m_collider)
            {
                collider.isTrigger = true;
            }
            
            if (ActionController.GetInstance().heldObject != null)
            {
                CloneObject(other);
            }
            else
            {
                CloneObject(other);
                
                objectIsOverlapping = true;
                
                _teleportedObject = other.gameObject;
            }

        }
        
        if (other.CompareTag("Laser"))
        {
            foreach (var collider in m_collider)
            {
                collider.isTrigger = true;
            }
            
            CloneObject(other);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Interactive"))
        {
            // Определение вектора направления от объекта к порталу
            Vector3 directionToPortal = (other.transform.position - transform.position).normalized;

            // Вычисление расстояния между объектом и порталом
            float distance = Vector3.Distance(other.transform.position, transform.position);

            // Увеличение размера клонированного объекта
            if (_cloneObject != null)
            {
                var originalLocalScale = other.transform.localScale;
                if (ActionController.GetInstance().heldObject != null)
                {
                    _cloneObject.transform.localScale = new Vector3(originalLocalScale.x / 2f, originalLocalScale.y / 2f, originalLocalScale.z / 2f);
                }
                else
                {
                    _cloneObject.transform.localScale = originalLocalScale;
                }
                
                // Установка новой позиции клонированного объекта относительно портала
                _cloneObject.transform.position = otherPortal.position + directionToPortal * distance;

                _cloneObject.transform.rotation = other.transform.rotation;
            }
        }else if (other.CompareTag("Laser"))
        {
            LineRenderer mainLineRenderer = other.GetComponent<LineRenderer>();

            // Начальная точка cloneLineRenderer
            Vector3 hitPoint = mainLineRenderer.GetPosition(1);
            hitPoint  = transform.InverseTransformPoint(hitPoint);
            Vector3 clonePosition = otherPortal.transform.TransformPoint(rotationOffset * hitPoint); 

            _cloneObject.transform.position = clonePosition;
            _cloneObject.transform.rotation = other.transform.rotation;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        var m_collider = wall.GetComponentsInChildren<Collider>();
        
        
        
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = false;
            
            foreach (var collider in m_collider)
            {
                collider.isTrigger = false;
            }
        }

        if (other.CompareTag("Interactive"))
        {
            if (ActionController.GetInstance().heldObject != null)
            {
                Destroy(_cloneObject);
            }
            else
            {
                Destroy(_cloneObject);
                
                objectIsOverlapping = false;
                
                _teleportedObject = null;
            }
            
            if (ActionController.GetInstance().heldObject == null)
            {
                foreach (var collider in m_collider)
                {
                    collider.isTrigger = false;
                }
            }
        }

        if (other.CompareTag("Laser"))
        {
            Destroy(_cloneObject);
            currentClones--;
        }
        
    }
    
    private void CloneObject(Collider originalCollider)
    {
        if (originalCollider.CompareTag("Interactive"))
        {
            Quaternion originalRotation = originalCollider.transform.rotation;
            Vector3 clonePosition = new Vector3(otherPortal.position.x, otherPortal.position.y, otherPortal.position.z);

            _cloneObject = Instantiate(originalCollider.gameObject, clonePosition, originalRotation);

            Collider colliderClone = _cloneObject.GetComponent<Collider>();
            colliderClone.enabled = false;
        } 
        else if (originalCollider.CompareTag("Laser") && currentClones < MaxClonesLaser)
        {
            LineRenderer mainLineRenderer = originalCollider.GetComponent<LineRenderer>();
            
            // Начальная точка cloneLineRenderer
            Vector3 hitPoint = mainLineRenderer.GetPosition(1);
            hitPoint  = transform.InverseTransformPoint(hitPoint);
            Vector3 clonePosition = otherPortal.transform.TransformPoint(rotationOffset * hitPoint);
            
            _cloneObject = Instantiate(originalCollider.gameObject, clonePosition, Quaternion.identity);
            
            currentClones++;
        }
    }
}
