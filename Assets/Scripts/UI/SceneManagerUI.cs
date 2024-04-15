using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;

public class SceneManagerUI : MonoBehaviour
{
    [Header("Menu Buttons")] 
    [SerializeField] private Button newGameButton;
    [SerializeField] private Button continueGameButton;

    private void Start()
    {
        if (!DataPersistenceManager.instance.HasGameData())
        {
            continueGameButton.interactable = false;
            TextMeshProUGUI textButton = continueGameButton.GetComponentInChildren<TextMeshProUGUI>();
            textButton.color = new Color(144f / 255f, 144f / 255f, 144f / 255f);
            ButtonManagerUI childrenUI = continueGameButton.GetComponent<ButtonManagerUI>();
            childrenUI.enabled = false;
        }
    }

    public void NewGame()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.NewGame();
        SceneManager.LoadSceneAsync("Level_001");
    }
    
    public void ContinueGame()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Level_001");
    }

    public void QuitGame() => Application.Quit();

    private void DisableMenuButtons()
    {
        newGameButton.interactable = false;
        continueGameButton.interactable = false;
    }
    
}
