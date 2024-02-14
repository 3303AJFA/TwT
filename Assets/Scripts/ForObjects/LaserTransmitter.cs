using System;
using Unity.VisualScripting;
using UnityEngine;

public class LaserTransmitter : MonoBehaviour
{
    public Transform point;
    
    private GameObject _cloneObject;
    
    private void OnCollisionEnter(Collision other)
    {
        if (other.collider.CompareTag("Laser"))
        {
            CloneObject(other);
        }
    }

    private void OnCollisionStay(Collision other)
    {
        LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();
            
        // Применяем масштаб клонированного объекта
        _cloneObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

        // Установка новой позиции клонированного объекта относительно портала
        cloneLineRenderer.SetPosition(0, new Vector3(point.position.x, point.position.y, point.position.z));

        _cloneObject.transform.position = cloneLineRenderer.GetPosition(0);
        _cloneObject.transform.rotation = point.rotation;
    }

    private void OnCollisionExit(Collision other)
    {
        if (other.collider.CompareTag("Laser"))
        {
            Destroy(_cloneObject);
        }
    }

    private void CloneObject(Collision originalCollision)
    {
        if (originalCollision.collider.CompareTag("Laser"))
        {
            LineRenderer mainLineRenderer = originalCollision.collider.GetComponent<LineRenderer>();
            
            Quaternion originalRotation = originalCollision.collider.transform.rotation;
            Vector3 clonePosition = new Vector3(point.position.x, point.position.y, point.position.z);

            _cloneObject = Instantiate(originalCollision.gameObject, clonePosition, originalRotation);

            Collider colliderClone = _cloneObject.GetComponent<Collider>();
            //colliderClone.enabled = false;
        }
    }
}
