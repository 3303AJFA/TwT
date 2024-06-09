using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManagerUI : MonoBehaviour
{
    public void ContinueGame()
    {
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Level_001");
        Time.timeScale = 1f;
        PauseGame.GameIsPaused = false;
    }
    
    public void QuitMainMenu()
    {
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("_MainMenu");
        Time.timeScale = 1f;
        PauseGame.GameIsPaused= false;
    }
    
    public void QuitGame() => Application.Quit();
    
    
}
