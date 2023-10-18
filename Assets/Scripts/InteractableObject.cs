using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractableObject : MonoBehaviour
{
    [SerializeField] private GameObject interactionHint;
    [SerializeField] private enum thisObjectType{PressableButton,Switch,Box,Sign};//Дополнительные штуки добавлены для теста.
    private void Start() {
        if(interactionHint){
            interactionHint.SetActive(false);
        }
    }
    private void OnTriggerEnter(Collider other) {
        if (other.tag == "Player" && interactionHint){
            interactionHint.SetActive(true);
        }
    }
    private void OnTriggerStay(Collider other) {
        
    }
    private void OnTriggerExit(Collider other) {
        if (other.tag == "Player" && interactionHint){
            interactionHint.SetActive(false);
        }
        
    }
}
