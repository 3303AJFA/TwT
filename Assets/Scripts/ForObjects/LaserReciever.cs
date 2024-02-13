using UnityEngine;

public class LaserReciever : MonoBehaviour
{
    [HideInInspector] public bool door;

    private void OnTriggerEnter(Collider cylinderCollider)
    {
        if (cylinderCollider.CompareTag("Laser"))
        {
            door = true;
            //Debug.Log("door: open");
        } 
    }
    
    private void OnTriggerExit(Collider cylinderCollider)
    {
        if (cylinderCollider.CompareTag("Laser"))
        {
            door = false;
            //Debug.Log("door: close");
        }
    }
}
