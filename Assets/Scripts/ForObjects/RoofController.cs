using System;
using System.Collections;
using UnityEngine;

public class RoofController : MonoBehaviour
{
    //private PlayerMovement _playerMovement;

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
    private Vector3 currentTarget;
    private Rigidbody playerRB;
    
    //[SerializeField] private float distanceThreshold = 2f;
    
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
            if (!_isExiting)
            {
                StartCoroutine(SmoothAlphaValue(_preRoofMr, _postRoofMr, 0f, _targetOpacity));
                isPlayerInside = true;
                CalculateTarget(other.transform.position);
                _isExiting = true;
            }
            else
            {
                StartCoroutine(SmoothAlphaValue(_postRoofMr, _preRoofMr, 0f, _targetOpacity));
                isPlayerInside = true;
                CalculateTarget(other.transform.position);
                _isExiting = false;
            }
        }
    }
    
    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            isPlayerInside = false;
            CalculateTarget(other.transform.position);
        }
    }
    
    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            CalculateTarget(other.transform.position);
        }
    }

    private void CalculateTarget(Vector3 playerPosition)
    {
        Vector3 direction = playerPosition - transform.position;

        if (isPlayerInside)
        {
            if (_isExiting)
            {
                currentTarget = beforeDoorPoint.position;
            } 
            else
            {
                currentTarget = currentTarget = afterDoorPoint.position;
            }
        }
        else
        {
            // Игрок снаружи триггера, притягиваем его в направлении движения
            currentTarget = transform.position + Vector3.Project(direction, transform.forward);
        }
    }
    
    private void PlayerMovement()
    {
        float step = pushForce * Time.deltaTime;
        Vector3 newPosition = Vector3.MoveTowards(playerRB.transform.position, currentTarget, step);
        
        // Обнуляем Y координату
        newPosition.y = playerRB.transform.position.y;
        
        // Применяем новую позицию к объекту игрока
        playerRB.transform.position = newPosition;
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
