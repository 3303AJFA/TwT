using System.Collections;
using UnityEngine;

public class SwitchButton : MonoBehaviour
{
    private Vector3 _originalPosition;
    private float moveDuration = 0.5f;
    
    private float _startTime;
    
    void Start()
    {
        _originalPosition = transform.position;
    }
    

    private void OnCollisionStay(Collision collison)
    {
        if ((collison.collider.tag == "Player" || collison.collider.tag == "Interactive") && transform.position.y >= _originalPosition.y - 0.5f)
        {
            transform.Translate(Vector3.forward * (-Time.fixedDeltaTime) * moveDuration, Space.Self);
        }
    }
    
    private void OnCollisionExit(Collision collison)
    {
        if (collison.collider.tag == "Player" || collison.collider.tag == "Interactive")
        {
            _startTime = Time.time;
            StartCoroutine(MoveToTargetY());
        }
    }
    
    private IEnumerator MoveToTargetY()
    {
        Vector3 startPosition = transform.position;
        float elapsedTime = 0f;

        while (elapsedTime < moveDuration)
        {
            elapsedTime = Time.time - _startTime;
            float t = Mathf.Clamp01(elapsedTime / moveDuration);
            transform.position = Vector3.Lerp(startPosition, _originalPosition, t);
            yield return null;
        }
        
        transform.position = _originalPosition;
    }
}
