using System.Collections;
using UnityEngine;

public class RoofController : MonoBehaviour, IDataPersistence
{
    [SerializeField] private string id;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }
    
    [SerializeField] private GameObject preRoof;
    [SerializeField] private GameObject postRoof;
    
    private MeshRenderer _preRoofMr;
    private MeshRenderer _postRoofMr;
    
    private bool _isExiting = false;
    private float _transitionDuration = 0.5f;
    private float _targetOpacity = 0.6f;

    [Header("Door Config")] 
    [SerializeField] private float pushForce = 5f;
    [SerializeField] private Transform beforeDoorPoint;
    [SerializeField] private Transform afterDoorPoint;
    
    private bool isPlayerInside = false;
    private bool _isFirstExit = false;
    private Vector3 currentTarget;
    private Rigidbody playerRB;
    
    private static readonly int Opacity = Shader.PropertyToID("_Opacity");

    private void Start()
    {
        _preRoofMr = preRoof.GetComponent<MeshRenderer>();
        _postRoofMr = postRoof.GetComponent<MeshRenderer>();
    }
    
    private void Update()
    {
        if (isPlayerInside)
        {
            // Притягиваем игрока к текущей цели
            PlayerMovement();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            playerRB = other.GetComponent<Rigidbody>();
            isPlayerInside = true;
            CalculateTarget();
            _isExiting = !_isExiting;
            
            StartCoroutine(SmoothAlphaValue(_isExiting ? _preRoofMr : _postRoofMr,
                _isExiting ? _postRoofMr : _preRoofMr,
                0f, _targetOpacity));
            
            _isFirstExit = true;
        }
    }
    
    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            isPlayerInside = false;
        }
    }

    private void CalculateTarget()
    {
        if (isPlayerInside)
        {
            currentTarget = _isExiting ? beforeDoorPoint.position : afterDoorPoint.position;
        }
    }
    
    private void PlayerMovement()
    {
        float step = pushForce * Time.deltaTime;
        Vector3 newPosition = Vector3.Lerp(playerRB.position, currentTarget, step);
        
        // Обнуляем Y координату
        newPosition.y = playerRB.position.y;
        
        // Применяем новую позицию к объекту игрока
        playerRB.position = newPosition;
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

    public void LoadData(GameData data)
    {
        data.isExited.TryGetValue(id, out _isExiting);
    }

    public void SaveData(GameData data)
    {
        if (data.isExited.ContainsKey(id))
        {
            data.isExited.Remove(id);
        }
        data.isExited.Add(id, _isFirstExit);
    }
}
