using UnityEngine;

[System.Serializable]
public class PreferenceData
{
    public bool firstStart;
    public float volumeSettings;
    public int qualityIndex;
    public bool isFullScreen;
    
    public PreferenceData()
    {
        firstStart = true;
        volumeSettings = 50;
        qualityIndex = 1;
        isFullScreen = true;
    }
}
