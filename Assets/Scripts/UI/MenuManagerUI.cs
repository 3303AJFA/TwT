using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManagerUI : MonoBehaviour
{
    public void ContinueGame()
    {
        SceneManager.LoadSceneAsync("Level_001");
        Time.timeScale = 1f;
        OpenMenuUI.GameIsPaused = false;
    }
    
    public void QuitMainMenu()
    {
        SceneManager.LoadSceneAsync("_MainMenu");
        Time.timeScale = 1f;
        OpenMenuUI.GameIsPaused = false;
    }
    
    public void QuitGame() => Application.Quit();
    
    
}
