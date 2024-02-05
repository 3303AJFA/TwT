using System.Linq.Expressions;
using UnityEngine;

public class SaveNLoadTransition : MonoBehaviour
{
    [SerializeField] private MeshRenderer meshRenderer;
    private bool _isTherePlayer = false;
    private bool _complite = false;
    
    private static readonly int Opacity = Shader.PropertyToID("_Opacity");

    private void Update()
    {
        if (_isTherePlayer && !_complite)
        {
            meshRenderer.material.SetFloat(Opacity, 0f);
            _complite = true;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player") && !_isTherePlayer)
        {
            _isTherePlayer = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player") && _isTherePlayer)
        {
            _isTherePlayer = false;
        }
    }
}
