using System.Collections;
using UnityEngine;

public class FoundSolutionUI : MonoBehaviour
{
    private Animation animator;

    private void Start() => animator = GameObject.FindGameObjectWithTag("FoundSolutionPanel").GetComponent<Animation>();

    public void UIAnimation() => animator.Play("FoundSolutionStart");
}
