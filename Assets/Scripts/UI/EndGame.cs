using UnityEngine;
using UnityEngine.SceneManagement;

public class EndGame : MonoBehaviour
{
    public void QuitMainMenu()
    {
        SceneManager.LoadSceneAsync("_MainMenu");
    }
}
