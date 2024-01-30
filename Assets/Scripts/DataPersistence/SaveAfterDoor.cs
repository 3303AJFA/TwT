using System;
using UnityEngine;

public class SaveAfterDoor : MonoBehaviour, IDataPersistence
{
    [SerializeField] private string id;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }
    
    [SerializeField] private Transform savePoint;
    [SerializeField] private bool isSaved = false;
    private bool _isLoaded = false;
    
    public void LoadData(GameData data)
    {
        GameObject.FindWithTag("Player").transform.position = data.playerPosition;
        data.checkPoints.TryGetValue(id, out isSaved);
        data.isLoaded.TryGetValue(id, out _isLoaded);
    }

    public void SaveData(ref GameData data)
    {
        if (isSaved && !_isLoaded)
        {
            data.playerPosition = savePoint.position;
            data.playerPosition.y = 0;
            
            if (data.checkPoints.ContainsKey(id))
            {
                data.checkPoints.Remove(id);
            }
            
            if (data.isLoaded.ContainsKey(id))
            {
                data.isLoaded.Remove(id);
            }

            _isLoaded = true;
            data.checkPoints.Add(id, isSaved);
            data.isLoaded.Add(id, _isLoaded);
        }
        
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !isSaved)
        {
            isSaved = true;
        }
    }
}
