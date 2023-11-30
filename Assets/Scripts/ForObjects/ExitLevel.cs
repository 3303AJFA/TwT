using UnityEngine;

public class ExitLevel : MonoBehaviour
{
    public LevelLoader levelLoader;
    
    private void OnTriggerEnter(Collider thisCollider)
    {
        if (thisCollider.CompareTag("Player"))
        {
            levelLoader.LoadNextLevel();
        }
    }
}
