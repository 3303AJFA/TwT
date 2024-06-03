using UnityEngine;

public class AudioInGameManager : MonoBehaviour
{
    [Header ("AudioSource")]
    [SerializeField] private AudioSource musicSource;
    [SerializeField] private AudioSource SFXSource;

    [Header ("AudioClip")]
    public AudioClip background;
    public AudioClip findSolution;
    

    private void Start()
    {
        musicSource.clip = background;
        musicSource.Play();
    }

    public void PlaySFX(AudioClip clip)
    {
        SFXSource.PlayOneShot(clip);
    }
}
