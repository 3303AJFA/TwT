using System.Collections;
using UnityEngine;

public class RoofController : MonoBehaviour
{
    [SerializeField] private GameObject preRoof;
    [SerializeField] private GameObject postRoof;
    
    private MeshRenderer _preRoofMr;
    private MeshRenderer _postRoofMr;
    
    private bool _isExiting = false;
    private float _transitionDuration = 0.5f;
    private float _targetOpacity = 0.6f;
    
    private static readonly int Opacity = Shader.PropertyToID("_Opacity");

    private void Start()
    {
        _preRoofMr = preRoof.GetComponent<MeshRenderer>();
        _postRoofMr = postRoof.GetComponent<MeshRenderer>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (!_isExiting)
            {
                StartCoroutine(SmoothAlphaValue(_preRoofMr, _postRoofMr, 0f, _targetOpacity));
                _isExiting = true;
            }
            else
            {
                StartCoroutine(SmoothAlphaValue(_postRoofMr, _preRoofMr, 0f, _targetOpacity));
                _isExiting = false;
            }
        }
    }

    IEnumerator SmoothAlphaValue(MeshRenderer startRoof, MeshRenderer endRoof, float startOpacity, float targetOpacity)
    {
        float elapsedTime = 0f;

        while (elapsedTime < _transitionDuration)
        {
            elapsedTime += Time.deltaTime;
            float t = Mathf.Clamp01(elapsedTime / _transitionDuration);
            float newOpacity = Mathf.Lerp(startOpacity, targetOpacity, t);

            startRoof.material.SetFloat(Opacity, newOpacity);
            endRoof.material.SetFloat(Opacity, targetOpacity - newOpacity);

            yield return null;
        }
    }
}
