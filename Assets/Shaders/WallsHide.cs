using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Shaders
{
    public class WallsHide : MonoBehaviour
    {
        private static int SizeID = Shader.PropertyToID("_Size");
        
        [SerializeField] private LayerMask _layerMask;
        [SerializeField] private Shader _hideShader;
        
        private Camera _camera;
        private Dictionary<int, float> _currentSizes = new Dictionary<int, float>();
        private Dictionary<int, GameObject[]> _layerObjects = new Dictionary<int, GameObject[]>();
        private List<int> _previousLayers = new List<int>();
        
        private float _transitionDuration = 0.1f;

        private void Start() {
            _camera = Camera.main;
        }
            
        private void LateUpdate()
        {
            RaycastHit[] hits = Physics.RaycastAll(transform.position, _camera.transform.position - transform.position, Mathf.Infinity, _layerMask);
            

            HashSet<int> activeLayers = new HashSet<int>();

            // Process hits
            foreach (var hit in hits)
            {
                MeshRenderer meshRenderer = hit.transform.GetComponent<MeshRenderer>();

                if (meshRenderer != null && meshRenderer.material.shader == _hideShader)
                {
                    int layer = hit.transform.gameObject.layer;
                    activeLayers.Add(layer);
                    ProcessMaterialsInLayer(layer);
                }
            }

            // Remove inactive layers
            foreach (var layer in _previousLayers)
            {
                if (!activeLayers.Contains(layer))
                {
                    ApplySmoothSizeValueDown(layer);
                }
            }

            // Update active and previous layers
            _previousLayers.Clear();
            _previousLayers.AddRange(activeLayers);
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
            if (_layerObjects.ContainsKey(layer))
            {
                return _layerObjects[layer];
            }
            GameObject[] allObjects = GameObject.FindGameObjectsWithTag("Walls");
            List<GameObject> objectsInLayer = new List<GameObject>();
    
            foreach (var obj in allObjects)
            {
                if (obj.layer == layer)
                {
                    objectsInLayer.Add(obj);
                }
            }
    
            _layerObjects[layer] = objectsInLayer.ToArray();
            return _layerObjects[layer];
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
