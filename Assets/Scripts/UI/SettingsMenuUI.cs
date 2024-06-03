using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UIElements;
using TMPro;

public class SettingsMenuUI : MonoBehaviour
{
    public AudioSource musicSource;

    public GameObject fullscreenToggle;
    public TMP_Dropdown qualityDropdown;
    public Slider volumeSlider;

    private float _volumeSettings;
    private int _qualitySettings;
    private bool _isFullScreenSettings;

    public void SetVolume(float volume)
    {
        _volumeSettings = volume;
        musicSource.volume = _volumeSettings;
    }

    public void SetQuality(int qualityIndex)
    {
        _qualitySettings = qualityIndex;
        QualitySettings.SetQualityLevel(qualityIndex);
    }

    public void SetFullscreen(bool isFullscreen)
    {
        _isFullScreenSettings = isFullscreen;
        Screen.fullScreen = isFullscreen;
    }

    public void SaveSettings()
    {
        DataPreferenceManager.instance.SaveGame();
    }

    public void LoadData(PreferenceData data)
    {
        _volumeSettings = data.volumeSettings;
        _qualitySettings = data.qualityIndex;
        _isFullScreenSettings = data.isFullScreen;
        
        /*musicSource.volume = data.volumeSettings;
        QualitySettings.SetQualityLevel(data.qualityIndex);
        Screen.fullScreen = data.isFullScreen;*/
    }

    public void SaveData(PreferenceData data)
    {
        data.volumeSettings = musicSource.volume;
        data.qualityIndex = _qualitySettings;
        data.isFullScreen = _isFullScreenSettings;
    }
}
