using UnityEngine;

public class WallsHide : MonoBehaviour
{
    private static int PositionID = Shader.PropertyToID("_Position");
    private static int SizeID = Shader.PropertyToID("_Size");
    
    [SerializeField] private Material[] wallMaterials = new Material[4];
    [SerializeField] private Camera _camera;
    [SerializeField] private LayerMask _layerMask;

    private void FixedUpdate()
    {
        Vector3 direction = _camera.transform.position - transform.position;
        Ray hit = new Ray(transform.position, direction.normalized);
        
        for (int i = 0; i < wallMaterials.Length; i++)
        {
            if(Physics.Raycast(hit, 3000, _layerMask))
                wallMaterials[i].SetFloat(SizeID, 1);
            else
                wallMaterials[i].SetFloat(SizeID, 0);
            
            Vector3 view = _camera.WorldToViewportPoint(transform.position);
            wallMaterials[i].SetVector(PositionID,view);
        }
        
    }
}
