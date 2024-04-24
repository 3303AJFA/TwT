using UnityEngine;

[System.Serializable]
public class GameData
{
    public Vector3 playerPosition;
    public SerializableDictionary<string, Vector3> doorPositions;
    public SerializableDictionary<string, bool> checkPoints;
    public SerializableDictionary<string, bool> isLoaded;
    public SerializableDictionary<string, bool> isExited;

    public float volumeSettings;
    public int qualityIndex;
    public bool isFullScreen;
    
    public GameData()
    {
        playerPosition = new Vector3(2,1.2f,2);
        doorPositions = new SerializableDictionary<string, Vector3>();
        checkPoints = new SerializableDictionary<string, bool>();
        isLoaded = new SerializableDictionary<string, bool>();
        isExited = new SerializableDictionary<string, bool>();

        volumeSettings = 50;
        qualityIndex = 1;
        isFullScreen = true;
        
    }
}
