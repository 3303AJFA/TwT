using System;
using Unity.VisualScripting;
using UnityEngine;

public class PortalTeleport : MonoBehaviour
{
    public Transform player;
    public Transform receiver;

    public GameObject wall;

    private GameObject _cloneObject;

    private bool playerIsOverlapping = false;

    private void Update()
    {
        if (playerIsOverlapping)
        {
            Vector3 portalToPlayer = player.position - transform.position;
            float dotProduct = Vector3.Dot(transform.up, portalToPlayer);

            if (dotProduct < 0f)
            {
                float rotationDiff = -Quaternion.Angle(transform.rotation, receiver.rotation);
                rotationDiff += 180;
                player.Rotate(Vector3.up, rotationDiff);

                Vector3 positionOffset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
                player.position = receiver.position + positionOffset;

                playerIsOverlapping = false;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        var m_collider = wall.GetComponent<Collider>();
        m_collider.isTrigger = true;
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = true;
        }

        //_cloneObject = Instantiate(other.GameObject());
    }
    
    private void OnTriggerExit(Collider other)
    {
        var m_collider = wall.GetComponent<Collider>();
        m_collider.isTrigger = false;
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = false;
        }

        //Destroy(_cloneObject);
    }
}
