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
        private GameObject[] _allWallObjects; // Кэшируем объекты с тегом "Walls"
        private Vector3 _lastCameraDirection;
        
        private float _transitionDuration = 0.1f;

        private void Start()
        {
            _camera = Camera.main;
            _allWallObjects = GameObject.FindGameObjectsWithTag("Walls"); 
            _lastCameraDirection = _camera.transform.position - transform.position; // Инициализируем направление камеры
        }

        private void LateUpdate()
        {
            Vector3 currentCameraDirection = _camera.transform.position - transform.position;
            
            if (currentCameraDirection != _lastCameraDirection)
            {
                _lastCameraDirection = currentCameraDirection;
                
                RaycastHit[] hits = Physics.RaycastAll(transform.position, _camera.transform.position - transform.position, Mathf.Infinity, _layerMask);

                HashSet<int> activeLayers = new HashSet<int>();

                // Process hits
                for (int i = 0; i < hits.Length; i++) // Используем for
                {
                    RaycastHit hit = hits[i];
                    MeshRenderer meshRenderer = hit.transform.GetComponent<MeshRenderer>();
                    if (meshRenderer != null && meshRenderer.material.shader == _hideShader)
                    {
                        int layer = hit.transform.gameObject.layer;
                        activeLayers.Add(layer);
                        ProcessMaterialsInLayer(layer);
                    }
                }

                // Remove inactive layers
                for (int i = 0; i < _previousLayers.Count; i++) // Используем for
                {
                    int layer = _previousLayers[i];
                    if (!activeLayers.Contains(layer))
                    {
                        ApplySmoothSizeValueDown(layer);
                    }
                }

                // Update active and previous layers
                _previousLayers.Clear();
                _previousLayers.AddRange(activeLayers);
            }
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

            List<GameObject> objectsInLayer = new List<GameObject>();

            for (int i = 0; i < _allWallObjects.Length; i++) // Используем for
            {
                GameObject obj = _allWallObjects[i];
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

                for (int i = 0; i < objects.Length; i++) // Используем for
                {
                    GameObject obj = objects[i];
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