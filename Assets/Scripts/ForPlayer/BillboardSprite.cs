using UnityEngine;

public class BillboardSprite : MonoBehaviour
{
     private void LateUpdate() { 
        transform.rotation = Quaternion.Euler(0f, Camera.main.transform.rotation.eulerAngles.y, 0f);
        //transform.LookAt(transform.position + Camera.main.transform.forward);
    }
}
