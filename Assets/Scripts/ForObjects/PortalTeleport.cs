using UnityEngine;

public class PortalTeleport : MonoBehaviour
{
    public Transform player;
    public Transform receiver;
    public GameObject wall;

    private GameObject _cloneObject;
    private bool playerIsOverlapping = false;

    private void Update()
    {
        PlayerTeleport();
    }

    private void PlayerTeleport()
    {
        if (playerIsOverlapping)
        {
            Vector3 portalToPlayer = player.position - transform.position;
            float dotProduct = Vector3.Dot(transform.up, portalToPlayer);

            if (dotProduct < 0f)
            {
                float rotationDiff = -Quaternion.Angle(transform.rotation, receiver.rotation);
                rotationDiff += 180;
                player.Rotate(Vector3.up, rotationDiff);

                Vector3 positionOffset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
                player.position = receiver.position + positionOffset;

                playerIsOverlapping = false;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        var m_collider = wall.GetComponent<Collider>();
        m_collider.isTrigger = true;
        
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = true;
        }
        else if (other.CompareTag("Interactive") || other.CompareTag("Laser"))
        {
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
                _cloneObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

                // Установка новой позиции клонированного объекта относительно портала
                _cloneObject.transform.position = receiver.position + directionToPortal * distance;

                _cloneObject.transform.rotation = other.transform.rotation;
            }
        }else if (other.CompareTag("Laser"))
        {
            // Применяем масштаб клонированного объекта
            _cloneObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

            // Установка новой позиции клонированного объекта относительно портала
            _cloneObject.transform.position = receiver.position;
            
            _cloneObject.transform.rotation = other.transform.rotation;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            var m_collider = wall.GetComponent<Collider>();
            m_collider.isTrigger = false;
            
            playerIsOverlapping = false;
        }

        Destroy(_cloneObject);
    }
    
    private void CloneObject(Collider originalCollider)
    {
        Quaternion originalRotation = originalCollider.transform.rotation;
        Vector3 clonePosition = new Vector3(receiver.position.x, receiver.position.y, receiver.position.z);

        _cloneObject = Instantiate(originalCollider.gameObject, clonePosition, originalRotation);

        Collider colliderClone = _cloneObject.GetComponent<Collider>();
        colliderClone.enabled = false;
    }
}