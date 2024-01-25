using System;
using UnityEngine;

public class SaveAfterDoor : MonoBehaviour, IDataPersistence
{
    [SerializeField] private Transform savePoint;
    [SerializeField] private bool isSaved = false;
    
    public void LoadData(GameData data)
    {
        GameObject.FindWithTag("Player").transform.position = data.playerPosition;
    }

    public void SaveData(ref GameData data)
    {
        if (!isSaved)
        {
            data.playerPosition = savePoint.position;
            isSaved = true;
        }
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") || isSaved == false)
        {
            // Access DataPersistenceManager instance
            DataPersistenceManager dataPersistenceManager = DataPersistenceManager.instance;

            // Save the game data through DataPersistenceManager
            dataPersistenceManager.SaveGame();
        }
    }
}
