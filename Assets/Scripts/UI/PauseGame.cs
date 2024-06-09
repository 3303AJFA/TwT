using UnityEngine;

public class PauseGame : MonoBehaviour
{
    public static bool GameIsPaused = false;

    private static PauseGame Instance;
    
    private void Awake()
    {
        if (Instance != null)
        {
            Debug.Log("Don't found Pause Game in the scene");
        }
        
        Instance = this;
    }
    
    public static PauseGame GetInstance()
    {
        return Instance;
    }

    public void Pause(GameObject elementUI)
    {
        elementUI.SetActive(true);
        Time.timeScale = 0f;
        GameIsPaused = true;
    }

    public void Resume(GameObject elementUI)
    {
        elementUI.SetActive(false);
        Time.timeScale = 1f;
        GameIsPaused = false;
    }
}
