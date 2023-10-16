using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionController : MonoBehaviour
{
    [SerializeField] private float pickUpRange;
    [SerializeField] private Transform holdParent;
    [SerializeField] private float moveForce;
    private GameObject _heldObject;
    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            if (_heldObject == null)
            {
                RaycastHit hit;
                if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, pickUpRange))
                {
                    PickupObject(hit.transform.gameObject);
                }
            }
            else
            {
                DropObject();
            }
                
        }

        if (_heldObject != null)
        {
            MoveObject();
        }
    }

    private void MoveObject()
    {
        if (Vector3.Distance(_heldObject.transform.position, holdParent.position) > 0.1f)
        {
            Vector3 moveDirection = (holdParent.position - _heldObject.transform.position);
            _heldObject.GetComponent<Rigidbody>().AddForce(moveDirection * moveForce);
        }
    }

    void PickupObject(GameObject pickObject)
    {
        if (pickObject.GetComponent<Rigidbody>())
        {
            Rigidbody objectRig = pickObject.GetComponent<Rigidbody>();
            objectRig.useGravity = false;
            objectRig.drag = 10;
            
            objectRig.transform.parent = holdParent;
            _heldObject = pickObject;
        }
    }

    void DropObject()
    {
        Rigidbody heldRig = _heldObject.GetComponent<Rigidbody>();
        heldRig.useGravity = true;
        heldRig.drag = 1;

        _heldObject.transform.parent = null;
        _heldObject = null;
    }
}
