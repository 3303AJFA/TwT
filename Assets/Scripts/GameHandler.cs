using System;
using UnityEngine;

public class GameHandler : MonoBehaviour
{
    [SerializeField] 
    private CameraFollow cameraFollow;
    [SerializeField] 
    private Transform playerTransform;
    


    private void Update()
    {
        cameraFollow.Setup(() => playerTransform.position);
    }
}
