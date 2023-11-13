using System;
using UnityEngine;

public class DoorController : MonoBehaviour
{
    [SerializeField]private TriggerAreaController triggerAreaController;
    [SerializeField]private Transform doorTransform;
    private float _maximumDoorTranslate = 0.1f;
    private Vector3 _defaultDoorTransform;

    private void Start()
    {
        _defaultDoorTransform = doorTransform.position;
    }

    // Update is called once per frame
    void Update()
    {
        if (triggerAreaController.door == true && doorTransform.position.y <= 5f)
        {
            transform.Translate(Vector3.up * _maximumDoorTranslate * Time.deltaTime);
        }
        else if (triggerAreaController.door == false && doorTransform.position.y > _defaultDoorTransform.y)
        {
            transform.Translate(Vector3.down * _maximumDoorTranslate * Time.deltaTime);
        }
    }
}
