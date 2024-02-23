using UnityEngine;

public class LaserController : MonoBehaviour
{
    private LineRenderer _lr;
    private Collider _laserCollider;
    private Rigidbody _playerRigidbody;
    
    [SerializeField] private float laserForce;
    [HideInInspector]public bool laserHitPlayer = false;
    private float _maxLaserDistance = 100f;
    private int _layerMask;

    void Start()
    {
        _lr = GetComponent<LineRenderer>();
        
        // Указываем слои игнорирования
        int laserLayer = LayerMask.NameToLayer("Laser");
        int barrierInteractiveLayer = LayerMask.NameToLayer("BarrierForInteractive");
        
        _laserCollider = GetComponent<Collider>();
        _layerMask = ~(1 << laserLayer) & ~(1 << barrierInteractiveLayer);
    }
    
    void FixedUpdate()
    {
        _lr.SetPosition(0, transform.position);
        RaycastHit hit;
        
        if (Physics.Raycast(transform.position, transform.forward, out hit, _maxLaserDistance, _layerMask))
        {
            if (hit.collider.CompareTag("Player") && !laserHitPlayer)
            {
                if (_playerRigidbody == null)
                {
                    _playerRigidbody = hit.collider.GetComponent<Rigidbody>();
                }
                
                if (_playerRigidbody != null)
                {
                    // Вычислить направление от попадания лазера к центру игрока
                    Vector3 forceDirection = _playerRigidbody.transform.position - hit.point;
                
                    // Нормализовать направление
                    forceDirection.Normalize();
                
                    // Приложить силу к игроку в направлении касательной от лазера
                    _playerRigidbody.AddForce(forceDirection * laserForce, ForceMode.Impulse);
                    laserHitPlayer = true;
                    Debug.Log("PLAYER TOUCH LASER");
                }
            }
            else
            {
                CurrentColliderSize(hit.distance + 0.5f);
                laserHitPlayer = false;
                _lr.SetPosition(1, hit.point);
            }
        }
        else
        {
            laserHitPlayer = false;
            Vector3 endPoint = transform.position + transform.forward * _maxLaserDistance;
            _lr.SetPosition(1, endPoint);
            CurrentColliderSize(_maxLaserDistance);
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
