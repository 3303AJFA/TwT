using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class SettingsMenuUI : MonoBehaviour
{
    public AudioSource musicSource;

    [SerializeField] private Toggle fullScreenToggle;
    [SerializeField] private Slider volumeSlider;
    [SerializeField] private TMP_Dropdown qualityDropdown;

    private void Awake()
    {
        musicSource.volume = PlayerPrefs.GetFloat("volume");
        QualitySettings.SetQualityLevel(PlayerPrefs.GetInt("quality"));
        Screen.fullScreen = PlayerPrefs.GetInt("fullScreen") == 1;

        volumeSlider.value = PlayerPrefs.GetFloat("volume");
        qualityDropdown.value = PlayerPrefs.GetInt("quality");
        fullScreenToggle.isOn = PlayerPrefs.GetInt("fullScreen") == 1;
    }

    public void SetVolume(float volume)
    {
        musicSource.volume = volume;
        PlayerPrefs.SetFloat("volume", volume);
    }

    public void SetQuality(int qualityIndex)
    {
        QualitySettings.SetQualityLevel(qualityIndex);
        PlayerPrefs.SetInt("quality", qualityIndex);
    }

    public void SetFullscreen(bool isFullscreen)
    {
        Screen.fullScreen = isFullscreen;
        PlayerPrefs.SetInt("fullScreen", isFullscreen ? 1 : 0);
    }
}
