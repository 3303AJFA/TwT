using UnityEngine;

public class OpenMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject pauseMenuUI;
    
    public void ActiveMenu()
    {
        if (PauseGame.GameIsPaused)
            PauseGame.GetInstance().Resume(pauseMenuUI);
        else
        {
            PauseGame.GetInstance().Pause(pauseMenuUI);
            if (DialogueManager.GetInstance().dialogueIsPlaying)
            {
                DialogueManager.GetInstance().ExitDialogueMode();
            }
        }
    }
}
