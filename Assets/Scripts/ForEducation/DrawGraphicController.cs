using UnityEngine;

public class DrawGraphicController : MonoBehaviour
{
    public Transform player;

    public LineRenderer vectorToPlayer;
    public LineRenderer vectorToY;
    
    void Update()
    {
        vectorToPlayer.SetPosition(0,transform.position);
        vectorToPlayer.SetPosition(1,player.position);
        
        vectorToY.SetPosition(0,transform.position);
        vectorToY.SetPosition(1,transform.position + transform.forward * 5);
    }
}
