using UnityEngine;
using UnityEngine.EventSystems;
using TMPro;

public class ButtonManagerUI : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField] private TextMeshProUGUI textButton;
    [SerializeField] private float scaleCff = 1.05f;
    [SerializeField] private float animationDuration = 0.2f;

    private Vector3 _originalScale;

    private void Awake()
    {
        _originalScale = textButton.transform.localScale;
    }
    
    public void OnPointerEnter(PointerEventData eventData)
    {
        LeanTween.scale(textButton.gameObject, _originalScale * scaleCff, animationDuration);
    }
    
    public void OnPointerExit(PointerEventData eventData)
    {
        LeanTween.scale(textButton.gameObject, _originalScale, animationDuration);
    }
}
