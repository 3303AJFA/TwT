using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class ChangePanelUI : MonoBehaviour
{
    [SerializeField] private Button settingsButton;
    [SerializeField] private Button controlsButton;

    [SerializeField] private GameObject settingsPanel;
    [SerializeField] private GameObject controlsPanel;

    private void Start()
    {
        SwitchPanelEffect(settingsButton, controlsButton);
    }

    public void OnSettingsButtonClick()
    {
        SwitchPanelEffect(settingsButton, controlsButton);
        
        settingsPanel.SetActive(true);
        controlsPanel.SetActive(false);
    }
    
    public void OnControlsButtonClick()
    {
        SwitchPanelEffect(controlsButton, settingsButton);

        settingsPanel.SetActive(false);
        controlsPanel.SetActive(true);
    }

    private void SwitchPanelEffect(Button firstButton, Button secondButton)
    {
        firstButton.interactable = false;
        TextMeshProUGUI FtextButton = firstButton.GetComponentInChildren<TextMeshProUGUI>();
        FtextButton.color = new Color(144f / 255f, 144f / 255f, 144f / 255f);
        ButtonManagerUI FchildrenUI = firstButton.GetComponent<ButtonManagerUI>();
        FchildrenUI.enabled = false;
        
        secondButton.interactable = true;
        TextMeshProUGUI StextButton = secondButton.GetComponentInChildren<TextMeshProUGUI>();
        StextButton.color = new Color(255f / 255f, 255f / 255f, 255f / 255f);
        ButtonManagerUI SchildrenUI = secondButton.GetComponent<ButtonManagerUI>();
        SchildrenUI.enabled = true;
    }
}
