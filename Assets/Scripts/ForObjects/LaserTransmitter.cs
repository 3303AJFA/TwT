using UnityEngine;

public class LaserTransmitter : MonoBehaviour
{
    private LaserController _laserController;
    
    public Transform point;
    
    private GameObject _cloneObject;
    private bool _isTransmit;
    
    void FixedUpdate()
    {
        if (_laserController != null) 
        {
            if (!_laserController.laserHitPlayer && _cloneObject != null)
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
    }
    
    private void OnCollisionEnter(Collision other)
    {
        if (other.collider.CompareTag("Laser") && !_isTransmit)
        {
            if (_laserController == null) _laserController = other.collider.GetComponent<LaserController>();
            
            if (!_laserController.laserHitPlayer) CloneObject(other);

            _isTransmit = true;
        }
    }

    private void OnCollisionStay(Collision other)
    {
        if (other.collider.CompareTag("Laser") && _cloneObject != null && !_laserController.laserHitPlayer && !_isTransmit)
        {
            LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();

            // Применяем масштаб клонированного объекта
            _cloneObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

            // Установка новой позиции клонированного объекта относительно портала
            cloneLineRenderer.SetPosition(0, new Vector3(point.position.x, point.position.y, point.position.z));

            _cloneObject.transform.position = cloneLineRenderer.GetPosition(0);
            _cloneObject.transform.rotation = point.rotation;
            
            _isTransmit = true;
        }
    }

    private void OnCollisionExit(Collision other)
    {
        if (_laserController != null)
        {
            if (other.collider.CompareTag("Laser") && !_laserController.laserHitPlayer)
            {
                Destroy(_cloneObject);
                _isTransmit = false;
            }
        }
    }

    private void CloneObject(Collision originalCollider)
    {
        Quaternion originalRotation = originalCollider.transform.rotation;
        Vector3 clonePosition = new Vector3(point.position.x, point.position.y, point.position.z);

        _cloneObject = Instantiate(originalCollider.gameObject, clonePosition, originalRotation);
    }
    
}
