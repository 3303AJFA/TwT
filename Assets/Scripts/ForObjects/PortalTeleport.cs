using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalTeleport : MonoBehaviour
{
    public PortalTeleport Other;
    
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerStay(Collider other)
    {
        float zPos = transform.worldToLocalMatrix.MultiplyPoint3x4(other.transform.position).z;

        if (zPos < 0) Teleport(other.transform);
    }

    private void Teleport(Transform obj)
    {
        Vector3 localPos = transform.worldToLocalMatrix.MultiplyPoint3x4(obj.position);
        localPos = new Vector3(-localPos.x, localPos.y*1.1f, localPos.z);
        obj.position = Other.transform.localToWorldMatrix.MultiplyPoint3x4(localPos);
        
        // Rotation
        Quaternion difference = Other.transform.rotation * Quaternion.Inverse(transform.rotation * Quaternion.Euler(0, 0, 180));
        obj.rotation = difference * obj.rotation;
    }
}
