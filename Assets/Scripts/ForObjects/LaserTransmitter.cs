using System;
using UnityEngine;

public class LaserTransmitter : MonoBehaviour
{
    private LaserController _laserController;
    
    public Transform point;
    private Renderer rendererTransmitter;
    
    private GameObject _cloneObject;
    private bool _isTransmit;

    private void Awake()
    {
        rendererTransmitter = transform.gameObject.GetComponent<Renderer>();
    }

    void FixedUpdate()
    {
        if (_laserController != null) 
        {
            if (!_laserController.laserHitPlayer && _cloneObject != null)
            {
                LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();

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
            
            if (rendererTransmitter != null && rendererTransmitter.materials.Length >= 2)
            {
                // Получение второго материала
                Material transmitterMaterial = rendererTransmitter.materials[1];

                // Включение Emission
                transmitterMaterial.EnableKeyword("_EMISSION");
            }
            else
            {
                Debug.LogWarning("Объект не имеет Renderer или второго материала.");
            }
            
            _isTransmit = true;
        }
    }

    private void OnCollisionStay(Collision other)
    {
        if (other.collider.CompareTag("Laser") && _cloneObject != null && !_laserController.laserHitPlayer && !_isTransmit)
        {
            LineRenderer cloneLineRenderer = _cloneObject.GetComponent<LineRenderer>();

            // Установка новой позиции клонированного объекта относительно портала
            cloneLineRenderer.SetPosition(0, new Vector3(point.position.x, point.position.y, point.position.z));

            _cloneObject.transform.position = cloneLineRenderer.GetPosition(0);
            _cloneObject.transform.rotation = point.rotation;
            
            _isTransmit = true;
        }
    }
    
    private void CloneObject(Collision originalCollider)
    {
        Quaternion originalRotation = originalCollider.transform.rotation;
        Vector3 clonePosition = new Vector3(point.position.x, point.position.y, point.position.z);

        _cloneObject = Instantiate(originalCollider.gameObject, clonePosition, originalRotation);
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
        
        if (rendererTransmitter != null && rendererTransmitter.materials.Length >= 2)
        {
            // Получение второго материала
            Material transmitterMaterial = rendererTransmitter.materials[1];

            // Включение Emission
            transmitterMaterial.DisableKeyword("_EMISSION");
        }
        else
        {
            Debug.LogWarning("Объект не имеет Renderer или второго материала.");
        }
    }

    
    
}
