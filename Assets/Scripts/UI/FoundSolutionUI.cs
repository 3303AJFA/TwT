
using UnityEngine;

public class FoundSolutionUI : MonoBehaviour
{
    private AudioInGameManager audioManager;
    private Animation animator;

    private void Awake()
    {
        audioManager = GameObject.FindGameObjectWithTag("Audio").GetComponent<AudioInGameManager>();
        animator = GameObject.FindGameObjectWithTag("FoundSolutionPanel").GetComponent<Animation>();
    }

    public void UIAnimation()
    {
        audioManager.PlaySFX(audioManager.findSolution);
        animator.Play("FoundSolutionStart");
    }
}
