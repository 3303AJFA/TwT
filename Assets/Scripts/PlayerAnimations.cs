using UnityEngine;

public class PlayerAnimations : MonoBehaviour
{
    [SerializeField] private Animator animator;

    public void IdleAnimation(Vector3 movement)
    {   
        animator.SetBool("isWalk",false);
        animator.SetFloat("AnimLastMoveX", movement.x);
        animator.SetFloat("AnimLastMoveZ", movement.z);
    }

    public void WalkAnimation(Vector3 movement)
    {
        animator.SetFloat("AnimMoveX", movement.x);
        animator.SetFloat("AnimMoveZ", movement.z);
        animator.SetBool("isWalk", movement.magnitude > 0.1f);
    }

    public void DashAnimation(Vector3 movement, bool isDash)
    {
        animator.SetFloat("AnimMoveX", movement.x);
        animator.SetFloat("AnimMoveZ", movement.z);
        animator.SetBool("isDash", isDash);
    }
}
