using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchButton : MonoBehaviour
{
    private Vector3 _originalPosition;
    
    void Start()
    {
        _originalPosition = transform.position;
    }
    

    public void OnTriggerStay(Collider collison)
    {
        if (collison.tag == "Player" && transform.position.y >= _originalPosition.y - 0.5f)
        {
            transform.Translate(Vector3.forward * (-Time.fixedDeltaTime), Space.Self);
        }
    }
    
    public void OnTriggerExit(Collider collison)
    {
        transform.position = _originalPosition;
    }
}
