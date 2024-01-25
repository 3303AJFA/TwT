using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

[System.Serializable]
public class GameData
{
    public Vector3 playerPosition;
    
    public GameData()
    {
        Debug.Log("player transform create");
        playerPosition = Vector3.zero;
    }
}
