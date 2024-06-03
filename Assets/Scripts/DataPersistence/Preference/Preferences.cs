using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Preferences : MonoBehaviour
{
    public AudioSource musicSource;
    
    private void Awake()
    {
        musicSource.volume = PlayerPrefs.GetFloat("volume");
        QualitySettings.SetQualityLevel(PlayerPrefs.GetInt("quality"));
        Screen.fullScreen = PlayerPrefs.GetInt("fullScreen") == 1;
    }
}
