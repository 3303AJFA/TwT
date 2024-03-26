using UnityEngine;

public class OpenMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject pauseMenuUI;

    public static bool GameIsPaused = false;
    
    public void ActiveMenu()
    {
        if (GameIsPaused)
            Resume();
        else
            Pause();
    }

    private void Resume()
    {
        pauseMenuUI.SetActive(false);
        Time.timeScale = 1f;
        GameIsPaused = false;
    }
    
    private void Pause()
    {
        pauseMenuUI.SetActive(true);
        Time.timeScale = 0f;
        GameIsPaused = true;
    }
}
