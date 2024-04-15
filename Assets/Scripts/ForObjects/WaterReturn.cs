using UnityEngine;

public class WaterReturn : MonoBehaviour
{
    [SerializeField] private Transform playerSpawnPoint;
    [SerializeField] private Transform interactiveSpawnPoint;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.transform.position = playerSpawnPoint.position;
        } 
        else if (other.CompareTag("Interactive"))
        {
            other.transform.position = interactiveSpawnPoint.position;

        }
    }
}
