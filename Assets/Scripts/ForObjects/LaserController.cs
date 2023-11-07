using UnityEngine;

public class LaserController : MonoBehaviour
{
    private LineRenderer _lr;
    
    void Start()
    {
        _lr = GetComponent<LineRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        _lr.SetPosition(0, transform.position);
        RaycastHit hit;
        if (Physics.Raycast(transform.position, transform.forward, out hit))
        {
            if (hit.collider)
            {
                _lr.SetPosition(1, hit.point);
            }
        }
        else _lr.SetPosition(1, transform.forward*5000);
    }
}
