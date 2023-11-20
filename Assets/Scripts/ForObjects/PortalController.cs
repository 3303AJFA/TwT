using UnityEngine;

namespace ForObjects
{
    public class PortalController : MonoBehaviour
    {
        public PortalController Other;
        public Camera PortalView;
        public Transform portalCamera;
        public Transform player;
        public Transform playerCamera;

        private void Start()
        {
            Other.PortalView.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
            GetComponentInChildren<MeshRenderer>().sharedMaterial.mainTexture = Other.PortalView.targetTexture;
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

            // Rotation
            Quaternion difference = transform.rotation *
                                    Quaternion.Inverse(Other.transform.rotation * Quaternion.Euler(0, 0, 180));
            PortalView.transform.rotation = difference * playerCamera.transform.rotation;

            // Clipping
            PortalView.nearClipPlane = lookerPosition.magnitude/(-1.3f);
        }
    }
}
