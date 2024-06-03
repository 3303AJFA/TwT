using UnityEngine;

public class AudioManager : MonoBehaviour
{
    [Header ("AudioSource")]
    [SerializeField] private AudioSource musicSource;

    [Header ("AudioClip")]
    public AudioClip background;
    

    private void Start()
    {
        musicSource.clip = background;
        musicSource.Play();
    }
}
