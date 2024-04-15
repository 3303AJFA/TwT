using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class EducationInputController : MonoBehaviour
{
    public Camera mainCamera;
    public Camera redCamera;
    public Camera blueCamera;
    
    public GameObject vectorY;
    public GameObject vectorToPlayer;

    public GameObject portal;
    public Transform target;

    private bool _moved;
    private Vector3 _originalPosition;

    private void Start()
    {
        _originalPosition = portal.transform.position;
    }

    private void FixedUpdate()
    {
        if (_moved)
        {
            portal.transform.position = Vector3.MoveTowards(portal.transform.position, target.position, 0.05f);
        }
        else
        {
            portal.transform.position = Vector3.MoveTowards(portal.transform.position, _originalPosition, 0.05f);
        }
    }

    public void OneClickAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            vectorY.SetActive(!vectorY.activeSelf);
            vectorToPlayer.SetActive(!vectorToPlayer.activeSelf);
        }
    }

    public void TwoClickAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            if (!_moved)
            {
                _moved = true;
                StartCoroutine(ChangeFOV(2f, 1.5f, mainCamera));
                StartCoroutine(ChangeFOV(2f, 1.5f, blueCamera));
                StartCoroutine(ChangeFOV(2f, 1.5f, redCamera));
            }
            else
            {
                _moved = false;
                StartCoroutine(ChangeFOV(4f, 1.5f, mainCamera));
                StartCoroutine(ChangeFOV(4f, 1.5f, blueCamera));
                StartCoroutine(ChangeFOV(4f, 1.5f, redCamera));
            }
        }
    }
    
    private IEnumerator ChangeFOV(float targetFOV, float duration, Camera camera)
    {
        float elapsedTime = 0f;
        float startingFOV = camera.orthographicSize;

        while (elapsedTime < duration)
        {
            camera.orthographicSize = Mathf.Lerp(startingFOV, targetFOV, elapsedTime / duration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        mainCamera.fieldOfView = targetFOV; // Убедиться, что конечное значение достигнуто
    }
}
