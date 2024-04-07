using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class DashController : MonoBehaviour
{
    private PlayerController _playerController;
    
    [SerializeField] private float dashSpeed;
    [SerializeField] private float dashTime;
    [SerializeField] private float dashCooldown;
    private float _lastDashTime;
    
    void Start()
    {
        _playerController = GetComponent<PlayerController>();
    }

    private bool CanDash()
    {
        return Time.time >= _lastDashTime + dashCooldown;
    }
    
    public void Dash(InputAction.CallbackContext context)
    {
        if ((context.performed && !_playerController.isDashing && CanDash()) && _playerController.lastMovementDirection != Vector3.zero)
        {
            //Debug.Log("Dash!!!");
            if (_playerController.movement.magnitude > 0.01f)
            {
                StartCoroutine(PerformDash());
            }
                
            //Debug.Log("Dash END");
        }
        
    }

    IEnumerator PerformDash()
    {
        _lastDashTime = Time.fixedTime;
        Vector3 dashDirection = _playerController.lastMovementDirection.normalized;
        _playerController.isDashing = true;
        
        /*if (Physics.OverlapBox(transform.position, 
                new Vector3(0.5f, 0.5f, 4/2), 
                Quaternion.LookRotation(dashDirection), 
                LayerMask.GetMask("Door")).Length != 0)
        {
            // Прерывание рывка при обнаружении препятствия
            _playerController.isDashing = false;
            yield break;
        }*/
        
        
        
        
        while (Time.fixedTime < _lastDashTime + dashTime)
        {
            // Применение силы для рывка (если нет препятствий)
            _playerController.rb.AddForce(dashDirection * dashSpeed, ForceMode.Impulse);
            if (!_playerController.isDashing)
                yield break;

            yield return null;
        }
        
        /*while (Time.fixedTime < _lastDashTime + dashTime)
        {             
            _playerController.rb.MovePosition(transform.position + dashDirection * dashSpeed * Time.fixedDeltaTime);

            if (!_playerController.isDashing)
                yield break;
            
            yield return null;
        }*/
        
        _playerController.isDashing = false;
        _playerController.playerAnimations.DashAnimation(_playerController.dir,_playerController.isDashing);
        _lastDashTime = Time.fixedTime;
    }
}
