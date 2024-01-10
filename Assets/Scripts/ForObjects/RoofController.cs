using System;
using UnityEngine;

public class RoofController : MonoBehaviour
{
    private GameObject _player;
    [SerializeField] private GameObject preRoof;
    [SerializeField] private GameObject postRoof;

    private void Start()
    {
        _player = GameObject.Find("Player");
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") )
        {
            
        }
    }
    
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player") )
        {
            
        }
    }
}
