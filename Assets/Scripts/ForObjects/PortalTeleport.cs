using System;
using UnityEngine;

public class PortalTeleport : MonoBehaviour
{
    public Transform player;
    public Transform otherPortal;
    public GameObject wall;

    private GameObject _cloneObject;
    private bool playerIsOverlapping = false;

    private const int MaxClonesLaser = 1;
    private int currentClones;
    private Quaternion rotationOffset;

    private void Start()
    {
        rotationOffset = Quaternion.Inverse(transform.rotation) * otherPortal.transform.rotation;
    }

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
                float rotationDiff = -Quaternion.Angle(transform.rotation, otherPortal.rotation);
                rotationDiff += 180;
                player.Rotate(Vector3.up, rotationDiff);

                Vector3 positionOffset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
                player.position = otherPortal.position + positionOffset;

                playerIsOverlapping = false;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        var m_collider = wall.GetComponentsInChildren<Collider>();
        for (int i = 0; i < m_collider.Length; i++)
        {
            m_collider[i].isTrigger = true;
        }
        
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = true;
        }
        
        if (other.CompareTag("Interactive") || other.CompareTag("Laser"))
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
                var originalLocalScale = other.transform.localScale;
                _cloneObject.transform.localScale = new Vector3(originalLocalScale.x / 2f, originalLocalScale.y / 2f, originalLocalScale.z / 2f);

                // Установка новой позиции клонированного объекта относительно портала
                _cloneObject.transform.position = otherPortal.position + directionToPortal * distance;

                _cloneObject.transform.rotation = other.transform.rotation;
            }
        }else if (other.CompareTag("Laser"))
        {
            LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();
            LineRenderer mainLineRenderer = other.GetComponent<LineRenderer>();

            // Начальная точка cloneLineRenderer
            Vector3 hitPoint = mainLineRenderer.GetPosition(1);
            hitPoint  = transform.InverseTransformPoint(hitPoint);
            Vector3 clonePosition = otherPortal.transform.TransformPoint(rotationOffset * hitPoint); 
            //cloneLineRenderer.SetPosition(0, new Vector3(clonePosition.x, mainLineRenderer.GetPosition(1).y, clonePosition.z));
            
            /*// Направление mainLineRenderer в локальные координаты портала
            Vector3 mainDirection = mainLineRenderer.GetPosition(1) - mainLineRenderer.GetPosition(0);
            mainDirection = transform.InverseTransformDirection(mainDirection);
            Vector3 cloneDirection = otherPortal.transform.TransformDirection(rotationOffset * mainDirection);
            
            // Конечная точка cloneLineRenderer
            Vector3 cloneEndPosition = clonePosition + cloneDirection;
            cloneLineRenderer.SetPosition(1, cloneEndPosition);*/

            _cloneObject.transform.position = clonePosition;
            _cloneObject.transform.rotation = other.transform.rotation;
            //Vector3 clonePosition = new Vector3(otherPortal.position.x, mainLineRenderer.GetPosition(1).y, otherPortal.position.z);
            //cloneLineRenderer.SetPosition(1, clonePosition + direction);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        var m_collider = wall.GetComponentsInChildren<Collider>();
        for (int i = 0; i < m_collider.Length; i++)
        {
            m_collider[i].isTrigger = false;
        }
        
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = false;
        }

        if (other.CompareTag("Interactive"))
        {
            Destroy(_cloneObject);
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
            
            LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();
            //cloneLineRenderer.SetPosition(0, new Vector3(clonePosition.x, mainLineRenderer.GetPosition(1).y, clonePosition.z));
            
            currentClones++;
            //cloneLineRenderer.SetPosition(1, clonePosition + newDirection);
        }
    }
}
