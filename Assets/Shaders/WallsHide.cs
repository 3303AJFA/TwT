using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Shaders
{
    public class WallsHide : MonoBehaviour
    {
        private static int SizeID = Shader.PropertyToID("_Size");
        
        [SerializeField] private Camera _camera;
        [SerializeField] private LayerMask _layerMask;
        [SerializeField] private Shader _hideShader;
        
        private Dictionary<int, float> _currentSizes = new Dictionary<int, float>();
        private List<int> _activeLayers = new List<int>();
        private List<int> _previousLayers = new List<int>();
        
        private float _transitionDuration = 0.1f;
            
        private void LateUpdate()
        {
            RaycastHit[] hits = Physics.RaycastAll(transform.position, _camera.transform.position - transform.position, Mathf.Infinity, _layerMask);

            // Process hits
            foreach (var hit in hits)
            {
                MeshRenderer meshRenderer = hit.transform.GetComponent<MeshRenderer>();
                if (meshRenderer != null && meshRenderer.material.shader == _hideShader)
                {
                    int layer = hit.transform.gameObject.layer;
                    if (!_activeLayers.Contains(layer))
                    {
                        _activeLayers.Add(layer);
                    }
                    ProcessMaterialsInLayer(layer);
                }
            }

            // Remove inactive layers
            foreach (var layer in _previousLayers)
            {
                if (!_activeLayers.Contains(layer))
                {
                    ApplySmoothSizeValueDown(layer);
                }
            }

            // Update active and previous layers
            _previousLayers.Clear();
            _previousLayers.AddRange(_activeLayers);
            _activeLayers.Clear();
        }
    
        private void ProcessMaterialsInLayer(int layer)
        {
            GameObject[] objectsInLayer = GetObjectsInLayer(layer);
    
            _currentSizes.TryAdd(layer, 0.0f);
    
            float targetSize = 1.0f;
    
            if (_currentSizes[layer] < targetSize)
            {
                StartCoroutine(SmoothSizeValue(objectsInLayer, layer, targetSize, true));
            }
                
        }
        
        private void ApplySmoothSizeValueDown(int layer)
        {
            GameObject[] objectsInLayer = GetObjectsInLayer(layer);
    
            _currentSizes.TryAdd(layer, 0.0f);
    
            StartCoroutine(SmoothSizeValue(objectsInLayer, layer, 0.0f, false));
        }
    
        private GameObject[] GetObjectsInLayer(int layer)
        {
            GameObject[] allObjects = GameObject.FindGameObjectsWithTag("Walls");
            List<GameObject> objectsInLayer = new List<GameObject>();
    
            foreach (var obj in allObjects)
            {
                if (obj.layer == layer)
                {
                    objectsInLayer.Add(obj);
                }
            }
    
            return objectsInLayer.ToArray();
        }
        
        
    
        IEnumerator SmoothSizeValue(GameObject[] objects, int layer, float targetSize, bool increaseSize)
        {
            float initialSize = _currentSizes[layer];
            float elapsedTime = 0f;
    
            while ((increaseSize && _currentSizes[layer] < targetSize) || (!increaseSize && _currentSizes[layer] > targetSize))
            {
                elapsedTime += Time.deltaTime;
                float t = Mathf.Clamp01(elapsedTime / _transitionDuration);
    
                float newSize = Mathf.Lerp(initialSize, targetSize, t);
    
                foreach (var obj in objects)
                {
                    if (obj.layer == layer)
                    {
                        MeshRenderer component = obj.GetComponent<MeshRenderer>();
                        if (component != null && component.material.shader == _hideShader)
                        {
                            component.material.SetFloat(SizeID, newSize);
                        }
                    }
                }
    
                _currentSizes[layer] = newSize;
    
                yield return null;
            }
    
            _currentSizes[layer] = targetSize;
        }
    }
}
