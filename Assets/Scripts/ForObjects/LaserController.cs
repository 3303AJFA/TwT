using System.Collections;
using UnityEngine;

public class LaserController : MonoBehaviour
{
    private LineRenderer _lr;
    
    [SerializeField] private float laserForce;
    public bool _laserHitPlayer = false;

    void Start()
    {
        _lr = GetComponent<LineRenderer>();
    }
    
    void FixedUpdate()
    {
        _lr.SetPosition(0, transform.position);
        RaycastHit hit;
        
        Debug.DrawRay(transform.position, transform.forward, Color.yellow,5000);
        if (Physics.Raycast(transform.position, transform.forward, out hit))
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
                else
                {
                    _laserHitPlayer = false;
                    _lr.SetPosition(1, hit.point);
                }
            }
        }
        else _lr.SetPosition(1, transform.forward*5000);
    }
}
