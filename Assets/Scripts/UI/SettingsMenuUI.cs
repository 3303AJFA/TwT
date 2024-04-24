using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UIElements;
using TMPro;

public class SettingsMenuUI : MonoBehaviour
{
    public AudioMixer audioMixer;

    public GameObject fullscreenToggle;
    public TMP_Dropdown qualityDropdown;
    public Slider volumeSlider;

    private float _volumeSettings;
    private int _qualitySettings;
    private bool _isFullScreenSettings;

    private void Awake()
    {
        //Screen.fullScreen = false;
        
        /*fullscreenToggle.toggle = _isFullScreenSettings;
        volumeSlider.value = _volumeSettings;
        qualityDropdown.value = _qualitySettings;*/
    }

    public void SetVolume(float volume)
    {
        _volumeSettings = volume;
        audioMixer.SetFloat("Volume", volume);
        DataPersistenceManager.instance.SaveGame();
    }

    public void SetQuality(int qualityIndex)
    {
        _qualitySettings = qualityIndex;
        QualitySettings.SetQualityLevel(qualityIndex);
        DataPersistenceManager.instance.SaveGame();
    }

    public void SetFullscreen(bool isFullscreen)
    {
        _isFullScreenSettings = isFullscreen;
        Screen.fullScreen = isFullscreen;
        DataPersistenceManager.instance.SaveGame();
    }

    public void LoadData(GameData data)
    {
        _volumeSettings = data.volumeSettings;
        _qualitySettings = data.qualityIndex;
        _isFullScreenSettings = data.isFullScreen;
        
        audioMixer.SetFloat("Volume", data.volumeSettings);
        QualitySettings.SetQualityLevel(data.qualityIndex);
        Screen.fullScreen = data.isFullScreen;
    }

    public void SaveData(GameData data)
    {
        data.volumeSettings = _volumeSettings;
        data.qualityIndex = _qualitySettings;
        data.isFullScreen = _isFullScreenSettings;
    }
}
