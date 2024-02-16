using System.Collections;
using UnityEngine;

public class LaserTransmitter : MonoBehaviour
{
    public Transform point;
    
    private GameObject _cloneObject;
    private bool _isTransmit;
    
    private void OnCollisionEnter(Collision other)
    {
        if (other.collider.CompareTag("Laser") && !_isTransmit)
        {
            CloneObject(other);
            
            _isTransmit = true;
        }
    }

    private void OnCollisionStay(Collision other)
    {
        if (other.collider.CompareTag("Laser") && _cloneObject != null)
        {
            LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();

            // Применяем масштаб клонированного объекта
            _cloneObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

            // Установка новой позиции клонированного объекта относительно портала
            cloneLineRenderer.SetPosition(0, new Vector3(point.position.x, point.position.y, point.position.z));

            _cloneObject.transform.position = cloneLineRenderer.GetPosition(0);
            _cloneObject.transform.rotation = point.rotation;
        }
    }

    private void OnCollisionExit(Collision other)
    {
        if (other.collider.CompareTag("Laser") && _isTransmit)
        {
            Destroy(_cloneObject);
            _isTransmit = false;
        }
    }

    private void CloneObject(Collision originalCollision)
    {
        Quaternion originalRotation = originalCollision.collider.transform.rotation;
        Vector3 clonePosition = new Vector3(point.position.x, point.position.y, point.position.z);

        _cloneObject = Instantiate(originalCollision.gameObject, clonePosition, originalRotation);
    }
    
}
