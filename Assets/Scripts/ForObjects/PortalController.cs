using UnityEngine;

namespace ForObjects
{
    public class PortalController : MonoBehaviour
    {
        public PortalController Other;
        public Camera PortalView;
        public Transform portalVisual;
        public Transform portalCamera;
        public Transform player;
        public Transform playerCamera;

        //[SerializeField] private int maxRecursionDepth = 8;

        private void Start()
        {
            Other.PortalView.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
            portalVisual.GetComponent<MeshRenderer>().sharedMaterial.mainTexture = Other.PortalView.targetTexture;
        }

        private void Update()
        {
            CameraPortal();
        }

        private void CameraPortal()
        {
            // Position
            Vector3 lookerPosition =
                Other.transform.worldToLocalMatrix.MultiplyPoint3x4(player.transform.position);
            lookerPosition = new Vector3(-lookerPosition.x, -lookerPosition.y, lookerPosition.z/2);
            portalCamera.transform.localPosition = lookerPosition;
            
            /*// Recursion
            CreateRecursiveView(Other, playerCamera.transform, maxRecursionDepth);*/

            // Rotation
            Quaternion difference = transform.rotation *
                                    Quaternion.Inverse(Other.transform.rotation * Quaternion.Euler(0, 0, 180));
            PortalView.transform.rotation = difference * playerCamera.transform.rotation;

            // Clipping
            PortalView.nearClipPlane = lookerPosition.magnitude/(-1.3f);
        }
        
        /*private void CreateRecursiveView(PortalController currentPortal, Transform currentCamera, int depth)
        {
            Matrix4x4 localToWorldMatrix = player.transform.localToWorldMatrix;
            Matrix4x4[] matrices = new Matrix4x4[depth];
            for (int i = 0; i < depth; i++)
            {
                localToWorldMatrix = transform.localToWorldMatrix * currentPortal.transform.worldToLocalMatrix *
                                     localToWorldMatrix;
                matrices[depth - i - 1] = localToWorldMatrix;
            }

            for (int i = 0; i < depth; i++)
            {
                portalCamera.transform.SetPositionAndRotation(matrices[i].GetColumn(3), matrices[i].rotation);
            }
        }*/
    }
}
