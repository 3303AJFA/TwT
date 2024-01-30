using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData
{
    public Vector3 playerPosition;
    public SerializableDictionary<string, bool> checkPoints;
    public SerializableDictionary<string, bool> isLoaded;
    
    public GameData()
    {
        Debug.Log("player transform create");
        playerPosition = Vector3.zero;
        checkPoints = new SerializableDictionary<string, bool>();
        isLoaded = new SerializableDictionary<string, bool>();
    }
}
