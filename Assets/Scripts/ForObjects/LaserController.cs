using System.Collections;
using UnityEngine;

public class LaserController : MonoBehaviour
{
    private LineRenderer _lr;
    private Collider _laserCollider;
    
    [SerializeField] private float laserForce;
    public bool _laserHitPlayer = false;
    public float maxLaserDistance = 100f;

    void Start()
    {
        _lr = GetComponent<LineRenderer>();
        _laserCollider = GetComponent<Collider>();
    }
    
    void FixedUpdate()
    {
        _lr.SetPosition(0, transform.position);
        RaycastHit hit;
        
        // Указываем слой лазера
        int laserLayer = LayerMask.NameToLayer("Laser");

        // Создаем маску, чтобы луч сталкивался с другими объектами, но игнорировал объекты на своем собственном слое
        int layerMask = 1 << laserLayer;

        
        if (Physics.Raycast(transform.position, transform.forward, out hit, maxLaserDistance, ~layerMask))
        {
            if (hit.collider)
            {
                if (hit.collider.gameObject.CompareTag("Player") && !_laserHitPlayer)
                {
                    // Получить компонент Rigidbody игрока
                    Rigidbody playerRigidbody = hit.collider.GetComponent<Rigidbody>();
                
                    if (playerRigidbody != null)
                    {
                        // Вычислить направление от попадания лазера к центру игрока
                        Vector3 forceDirection = playerRigidbody.transform.position - hit.point;
                
                        // Нормализовать направление
                        forceDirection.Normalize();
                
                        // Приложить силу к игроку в направлении касательной от лазера
                        playerRigidbody.AddForce(forceDirection * laserForce, ForceMode.Impulse);
                        _laserHitPlayer = true;
                        Debug.Log("PLAYER TOUCH LASER");
                    }
                }
                else if (hit.collider.gameObject.CompareTag("Portal"))
                {
                    _laserHitPlayer = false;
                    _lr.SetPosition(1, hit.point);
                    CurrentColliderSize(hit.distance);
                }
                else
                {
                    _laserHitPlayer = false;
                    _lr.SetPosition(1, hit.point);
                    CurrentColliderSize(hit.distance);
                }
            }
        }
        else
        {
            _laserHitPlayer = false;
            _lr.SetPosition(1, transform.position + transform.forward * maxLaserDistance);
            CurrentColliderSize(_lr.GetPosition(1).z);
        }
    }

    private void CurrentColliderSize(float newSize)
    {
        if (_laserCollider is BoxCollider boxCollider)
        {
            boxCollider.size = new Vector3(boxCollider.size.x, boxCollider.size.y, newSize*2);
            boxCollider.center = new Vector3(boxCollider.center.x, boxCollider.center.y, boxCollider.size.z / 2f);
        }
    }
}
