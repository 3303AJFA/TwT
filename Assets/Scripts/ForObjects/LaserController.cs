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
        
        // Указываем слои игнорирования
        int laserLayer = LayerMask.NameToLayer("Laser");
        int barrierInteractiveLayer = LayerMask.NameToLayer("BarrierForInteractive");

        // Создаем маску, чтобы луч сталкивался с другими объектами, но игнорировал объекты на своем собственном слое и слое барьера для луча и тд.
        int layerMask = ~(1 << laserLayer) & ~(1 << barrierInteractiveLayer);

        
        if (Physics.Raycast(transform.position, transform.forward, out hit, maxLaserDistance, layerMask))
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
            CurrentColliderSize(maxLaserDistance);
        }
    }

    private void CurrentColliderSize(float newSize)
    {
        if (_laserCollider is BoxCollider Collider)
        {
            Collider.size = new Vector3(Collider.size.x, Collider.size.y, newSize*2);
            Collider.center = new Vector3(Collider.center.x, Collider.center.y, Collider.size.z / 2f);
        }
    }
}
