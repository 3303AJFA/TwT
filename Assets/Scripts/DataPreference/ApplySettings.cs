using Unity.VisualScripting;
using UnityEngine;

public class ApplySettings : MonoBehaviour
{
    public void OnButtonClick()
    {
        DataPreferenceManager.instance.SaveGame();
    }
}
