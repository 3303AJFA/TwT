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
    //[SerializeField] private float distanceThreshold = 2f;
    
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
                Rigidbody playerRb = other.GetComponent<Rigidbody>();

                // Получаем центр коллайдера двери
                Vector3 doorCenter = GetComponent<Collider>().bounds.center;

                // Определение направления от игрока к центру коллайдера двери
                Vector3 directionToDoorCenter = doorCenter - other.transform.position;

                // Получаем вектор скорости игрока
                Vector3 playerVelocity = playerRb.velocity.normalized;

                // Выравниваем направление от игрока к центру двери с направлением его движения
                Vector3 pushDirection =
                    Vector3.ProjectOnPlane(directionToDoorCenter, playerVelocity).normalized * pushForce;

                // Применение силы с использованием Rigidbody
                playerRb.AddForce(pushDirection, ForceMode.Impulse);
                _isExiting = true;
            }
            else
            {
                StartCoroutine(SmoothAlphaValue(_postRoofMr, _preRoofMr, 0f, _targetOpacity));
                Rigidbody playerRb = other.GetComponent<Rigidbody>();

                // Получаем центр коллайдера двери
                Vector3 doorCenter = GetComponent<Collider>().bounds.center;

                // Определение направления от игрока к центру коллайдера двери
                Vector3 directionToDoorCenter = doorCenter - other.transform.position;

                // Получаем вектор скорости игрока
                Vector3 playerVelocity = playerRb.velocity.normalized;

                // Выравниваем направление от игрока к центру двери с направлением его движения
                Vector3 pushDirection =
                    Vector3.ProjectOnPlane(directionToDoorCenter, playerVelocity).normalized * pushForce;

                // Применение силы с использованием Rigidbody
                playerRb.AddForce(pushDirection, ForceMode.Impulse);
                _isExiting = false;
            }
        }
    }

    /*private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Rigidbody playerRb = other.GetComponent<Rigidbody>();

            // Получаем центр коллайдера двери
            Vector3 doorCenter = GetComponent<Collider>().bounds.center;

            // Определение направления от игрока к центру коллайдера двери
            Vector3 directionToDoorCenter = doorCenter - other.transform.position;

            // Получаем вектор скорости игрока
            Vector3 playerVelocity = playerRb.velocity.normalized;

            // Выравниваем направление от игрока к центру двери с направлением его движения
            Vector3 pushDirection =
                Vector3.ProjectOnPlane(directionToDoorCenter, playerVelocity).normalized * pushForce;

            // Применение силы с использованием Rigidbody
            playerRb.AddForce(pushDirection, ForceMode.Impulse);
        }
    }*/
    
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Rigidbody playerRb = other.GetComponent<Rigidbody>();
            playerRb.velocity = Vector3.zero; // Обнуляем скорость, чтобы избежать застревания
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
