using UnityEngine;

public class LaserController : MonoBehaviour
{
    private LineRenderer _lr;
    private Collider _laserCollider;
    private Rigidbody _playerRigidbody;
    private Animator _animator;
    private PlayerController _playerController;
    
    
    [SerializeField] private float laserForce;
    [HideInInspector] public bool laserHitPlayer = false;
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
                    _animator = _playerRigidbody.GetComponentInChildren<Animator>();
                    _playerController = _playerRigidbody.GetComponent<PlayerController>();
                }
                
                if (_playerRigidbody != null)
                {
                    if (_animator.GetCurrentAnimatorStateInfo(0).IsName("Dash"))
                    {
                        _playerController.isDashing = false;
                        _animator.SetBool("isDash", false);
                        
                        Vector3 pushDirection = _playerRigidbody.transform.position - hit.point;
                        pushDirection.Normalize();
                
                        // Приложить силу к игроку в направлении касательной от лазера
                        _playerRigidbody.AddForce(pushDirection * laserForce * 2, ForceMode.Impulse);
                        laserHitPlayer = true;
                    }
                    else
                    {
                        Vector3 pushDirection = _playerRigidbody.transform.position - hit.point;
                        pushDirection.Normalize();
                
                        // Приложить силу к игроку в направлении касательной от лазера
                        _playerRigidbody.AddForce(pushDirection * laserForce, ForceMode.Impulse);
                        laserHitPlayer = true;
                    }
                    
                    //Debug.Log("PLAYER TOUCH LASER");
                }
            }
            else if (hit.collider.CompareTag("Interactive"))
            {
                CurrentColliderSize(hit.distance + 0.4f);
                laserHitPlayer = false;
                _lr.SetPosition(1, hit.point);
            }
            else
            {
                CurrentColliderSize(hit.distance + 0.1f);
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
            boxCollider.size = new Vector3(boxCollider.size.x, boxCollider.size.y, newSize);
            boxCollider.center = new Vector3(boxCollider.center.x, boxCollider.center.y, boxCollider.size.z / 2f);
        }
    }
}
